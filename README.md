# Action Access
[![Build Status](https://travis-ci.org/matiasgagliano/action_access.svg?branch=master)](https://travis-ci.org/matiasgagliano/action_access)

Action Access is a **modular**, **concise** and really **easy** to use **access
control system** for Ruby on Rails. It allows to secure applications and handle
permissions in a breeze.

* Focuses on what **actions** are accessible for the current user instead of
messing with models and their attributes.

* **Declarative** and **succinct** authorization statements right in the
controller. Everything related to a controller is within the controller
(self-contained) so that **no stale code** is left behind when
refactoring, moving or removing controllers.

* Totally **independent** from the authentication system and can work without
user models or predefined roles.

* Batteries are included, **utilities** for thorough control and useful
**view helpers** come out of the box.

* No configuration files, rake tasks or migrations needed.


## Installation

Add `action_access` to the app's Gemfile, run the `bundle` command and restart
any running server.

```ruby
# Gemfile
gem 'action_access'
```


## Basic configuration

The most important setting is how to get the **clearance levels** (roles,
credentials, user groups, etc.) for the current session, other than that it
works out of the box.

Action Access doesn't require users or authentication at all to function so
you can get creative with the way you set and identify clearance levels.

It only needs a `current_clearance_levels` method that returns the
clearance levels granted for the current request. It can be a single clearance
level (string or symbol) or a list of them (array), and it doesn't matter if
they're singular or plural (they'll be singularized).

  * With `current_user`:

    The default `current_clearance_levels` method tests if it can get
    `current_user.clearance_levels` and defaults to `:guest` if not.

    So, if you already have a `current_user` method you just need to add a
    `clearance_levels` method to the user. With a role based authorization you
    may add the following to your `User` model:

    ```ruby
    class User < ActiveRecord::Base
      belongs_to :role

      def clearance_levels
        # Single role name
        role.name
      end
    end
    ```

    or

    ```ruby
    class User < ActiveRecord::Base
      has_and_belongs_to_many :roles

      def clearance_levels
        # Array of role names
        roles.pluck(:name)
      end
    end
    ```


  * No `current_user`:

    If there's no `current_user` you need to override `current_clearance_levels`
    with whatever logic applies to your application.

    Continuing with the role based example, you might do something like this:

    ```ruby
    class ApplicationController < ActionController::Base
      def current_clearance_levels
        session[:role] || :guest
      end
    end
    ```


## Setting permissions

Permissions are set through authorization statements using the **let** class
method available in every controller. It takes the clearance levels (plural or
singular) first and the action or list of actions (array) as the last parameter.

As a simple example, to allow administrators (and only administrators in this
case) to delete articles you'd add the following to `ArticlesController`:

```ruby
class ArticlesController < ApplicationController
  let :admins, :destroy

  def destroy
    # ...
  end

  # ...
end
```

This will automatically **lock** the controller and only allow administrators
accessing the destroy action. **Every other request** pointing to the controller
**will be rejected** and redirected with an alert.


### Real-life example:

```ruby
class ArticlesController < ApplicationController
  let :admins, :all
  let :editors, :reviewers, [:edit, :update]
  let :editors, :destroy
  let :all, [:index, :show]

  def index
    # ...
  end

  # ...
end
```

These statements lock the controller and set the following:
 * _Administrators_ (admins) are authorized to access any action.
 * _Editors_ can list, view, edit and destroy articles (can't create).
 * _Reviewers_ can list, view and edit articles.
 * _Anyone else_ can **only** list and view articles.

This case uses the special keyword `:all`. It means everyone if passed as the
first argument or every action if passed as the last one.

Again, any unauthorized request will be rejected and redirected with an alert.


### Note about clearance levels

Notice that in the previous examples we didn't need to define clearance levels
or roles anywhere else in the application. With the authorization statements
you both **define** them and **set their permissions**. The only requirement is
that the clearance levels from the authorizations match at least one from the
list returned by `current_clearance_levels`.

This makes it easier to embrace modular designs, makes controllers to be
self-contained and avoids leaving unnecessary or unused code after refactoring.


## Advanced configuration

### Locked by default

The `lock_access` class method forces controllers to be locked even if no
permissions are defined, in such case every request will be redirected.

This allows to ensure that an entire application or scope (e.g. `Admin`) is
**locked by default**. Simply call `lock_access` inside `ApplicationController`
or from a scope's base controller.

```ruby
class ApplicationController < ActionController::Base
  lock_access

  # ...
end
```

To **unlock** a single controller (to make it "public") add `let :all, :all`,
this will allow anyone to access any action in the controller.


### Redirection path

By default any unauthorized (or not explicitly authorized) access will be
redirected to the **root path**.

You can set or choose a different path by overriding the somewhat long but
very clear `unauthorized_access_redirection_path` method.

```ruby
class ApplicationController < ActionController::Base

  def unauthorized_access_redirection_path
    # Ensure an array of symbols
    clearance_levels = Array(current_user.clearance_levels).map(&:to_sym)

    # Choose a redirection path
    return admin_root_path if clearance_levels.include?(:admin)
    return user_root_path  if clearance_levels.include?(:user)
    root_path
  end

  # ...
end
```


### Alert message

Redirections have a default alert message of "Not authorized.". To customize it
or use translations set `action_access.redirection_message` in your locales.

```yml
# config/locales/en.yml
en:
  action_access:
    redirection_message: "You are not allowed to do this!"
```


## Utilities

### Fine Grained Access Control

If further control is required, possibly because access depends on request
parameters or some result from the database, you can use the `not_authorized!`
method inside actions to reject the request and issue a redirection. It
optionally takes a redirection path and a custom alert message.

```ruby
class ProfilesController < ApplicationController
  let :user, [:edit, :update]

  def update
    unless params[:id] == current_user.profile_id
      not_authorized! path: profile_path, message: "That's not your profile!"
    end

    # ...
  end

  # ...
end
```

There are better ways to handle this particular case but it serves to outline
the use of `not_authorized!` inside actions.


### Model additions

Action Access is bundled with some model utilities too. By calling
`add_access_utilities` in any model it will extend it with a `can?` instance
method that checks if the entity (commonly a user) is authorized to perform a
given action on a resource.

`can?` takes two arguments, the action and the resource, and a namespace option
if needed. The resource can be a string, symbol, controller class or model
instance. Action Access will do the possible to get the right controller out
of the resource and the namespace (optional). In the end it returns a boolean.

**Some examples:**

```ruby
@user.can? :edit, :articles, namespace: :admin
@user.can? :edit, @admin_article                       # Admin::Article instance
@user.can? :edit, Admin::ArticlesController
# True if the user's clearance levels allow her to access 'admin/articles#edit'.
```

Just like the default `current_clearance_levels` in controllers, `can?`
depends on a `clearance_levels` method in the model too.

Following up the `User` model from before:

```ruby
class User < ActiveRecord::Base
  add_access_utilities

  has_and_belongs_to_many :roles

  # Don't forget this!
  def clearance_levels
    # Array of role names
    roles.pluck(:name)
  end
end
```

```erb
<% if current_user.can? :edit, :articles %>
  <%= link_to 'Edit article', edit_article_path(@article) %>
<% end %>
```

### The keeper

The **keeper** is the core of Action Access, it's the one that registers
permissions and who decides if a clearance level grants access or not.

It's available as `keeper` within controllers and views and as
`ActionAccess::Keeper.instance` anywhere else. You can use it to check
permissions with the `lets?` method, which takes the clearance level (only one)
as the first argument and the rest are the same as for `can?`.

```ruby
# Filter a list of roles to only those that allow to edit articles.
roles.select { |role| keeper.lets? role, :edit, :articles }
```


## License

Action Access is released under the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2014 Matías A. Gagliano.


## Contributing

If you have *questions*, found an *issue* or want to submit a *pull request* you
must read the [CONTRIBUTING file](CONTRIBUTING.md).

- **DO NOT** use the issue tracker for **questions** or to require help, there
are other means for that (see the CONTRIBUTING file).

- **ALWAYS** open an issue before submitting a **pull request**, it won't be
accepted otherwise. Discussing changes beforehand will make your work much
more relevant.

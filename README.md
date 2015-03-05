# Action Access
[![Build Status](https://travis-ci.org/matiasgagliano/action_access.svg?branch=v0.0.2)](https://travis-ci.org/matiasgagliano/action_access)
[![Security](https://hakiri.io/github/matiasgagliano/action_access/master.svg)](https://hakiri.io/github/matiasgagliano/action_access/master)

Action Access is an access control system for Ruby on Rails. It provides a
modular and easy way to secure applications and handle permissions.

It works at controller level focusing on what **actions** are accessible for
the current user instead of handling models and their attributes.

It also provides utilities for thorough control and some useful view helpers.


## Installation

Add `action_access` to the app's Gemfile, run the `bundle` command and restart
any running server.

```ruby
# Gemfile
gem 'action_access'
```


## Basic configuration

The most important setting is the way to get the **clearance level** (role,
user group, etc.), other than that it works out of the box.

Action Access doesn't require users or authentication at all to function so
you can get creative with the way you set and identify clearance levels.

It only needs a `current_clearance_level` method that returns the proper
clearance level for the current request. It can be a string or symbol and
it doesn't matter if it's singular or plural, it'll be singularized.

  * With `current_user`:

    The default `current_clearance_level` method tests if it can get
    `current_user.clearance_level` and defaults to `:guest` if not.

    So, if you already have a `current_user` method you just need to add a
    `clearance_level` method to the user. With a role based authorization you
    may add the following to your `User` model:

    ```ruby
    class User < ActiveRecord::Base
      belongs_to :role

      def clearance_level
        role.name
      end
    end
    ```

  * No `current_user`:

    If there's no `current_user` you need to override `current_clearance_level`
    with whatever logic that applies to your application.

    Continuing with the role based example, you might do something like this:

    ```ruby
    class ApplicationController < ActionController::Base
      def current_clearance_level
        session[:role] || :guest
      end
    end
    ```


## Setting permissions

Permissions are set through authorization statements using the **let** class
method available in every controller. The first parameter is the clearance
level (plural or singular) and the second is the action or list of actions.

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
  let :editors, [:index, :show, :edit, :update]
  let :all, [:index, :show]

  def index
    # ...
  end

  # ...
end
```

These statements lock the controller and set the following:
 * _Administrators_ (admins) are authorized to access any action.
 * _Editors_ can list, view and edit articles.
 * _Anyone else_ can **only** list and view articles.

This case uses the special keyword `:all`, it means everyone if passed as the
first argument or every action if passed as the second one.

Again, any unauthorized request will be rejected and redirected with an alert.

### Note about clearance levels

Notice that in the previous examples we didn't need to define clearance levels
or roles anywhere else in the application. With the authorization statement you
both **define** them and **set their permissions**. The only requirement is
that the clearance levels from the authorizations match the one returned by
`current_clearance_level`.


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

  def unathorized_access_redirection_path
    case current_user.clearance_level.to_sym
      when :admin then admin_root_path
      when :user  then user_root_path
      else root_path
    end
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
# True if the user's clearance level allows her to access 'admin/articles#edit'.
```

`can?` depends on a `clearance_level` method in the model so don't forget it.
Continuing with the `User` model from before:

```ruby
class User < ActiveRecord::Base
  add_access_utilities

  belongs_to :role

  def clearance_level
    role.name
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
permissions with the `lets?` method, which takes the clearance level as the
first argument and the rest are the same as for `can?`.

```ruby
# Filter a list of users to only those allowed to edit articles.
@users.select { |user| keeper.lets? user.role.name, :edit, :articles }
```


## License

Action Access is released under the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2014 Matías A. Gagliano.


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

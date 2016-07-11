Changelog
=========

0.1.1
-----

- Support Rails 5.


0.1.0
-----

**Features:**

- Support sessions with multiple clearance levels (e.g. users with many roles).
- Avoid repetition when defining clearance levels with the same permissions.

**API:**

- Use `current_clearance_levels` (plural) instead of `current_clearance_level`.
- Use `clearance_levels` (plural) instead of `clearance_level` (model method).


0.0.3
-----

- Update dependencies.
- Support Ruby 2.2.2.


0.0.2
-----

- Speed up tests with in-memory database.


0.0.1
-----

- Initial release.

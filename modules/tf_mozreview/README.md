Terraform MozReview module
========================

A Terraform module to create a MozReview AWS stack

Input Variables
---------------
- `name` - Name of the MozReview stack

Modules Usage
-------------

```js
module "mozreview" {
  source = "github.com/dividehex/tf_mozreview"

  name = "MozReview"
}
```


Outputs
-------
- TBD

Authors
=======

[Jake Watkins](https://github.com/dividehex)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.


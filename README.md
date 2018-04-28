The Problem
===========
The following has happened to me an embarrassing number of times, and I've seen
it happen to many others: A new source file is created and added to the build
system, but not added to the git commit.  This typically results in a shameful
build break either when CI does it job or someone else pulls the change.

The Solution
============
My solution is basic and general.  A git hook checks if any of the untracked
files appear as added/changed content in the diff of the commit.  This catches
the majority of instances where the problem occurs in practice.

Limitations
===========
There area few limitations:

 - The hook won't catch new files that are implicitly handled.  For example,
   some test systems will automatically run any tests that appear in a
   directory.  The hook cannot catch these types of mistakes.

 - The hook can have some false positives - for example, if the name of the
   untracked file just happens to appear in the commit for some unrelated
   reason.

Usage
=====

1. Copy `git-install-missing-file-hook` into your path.
2. Run `git install-missing-file-hook repo`, to install a pre-commit hook into
   a repo.

The script will refuse to install if .git/hooks/pre-commit already exists.  In
that case, you should integrate the script manually.

If you want to remove the hook, then remove .git/hooks/pre-commit manually.

Potential Other Approaches
==========================
The approach implemented here is simple and works well in a wide variety of
project types.  However, there are more sophisticated approaches
such as:

* Leveraging the build system to accurately identify when required dependencies
  are not committed.  This could end up being rather language specific, but the
  result may be more accurate for said language.

* A hook to do a pre-commit build+test with a clean environment.  This is
  impractical for larger projects, but would likely work very well for small
  (fast to build, fast to test) ones.


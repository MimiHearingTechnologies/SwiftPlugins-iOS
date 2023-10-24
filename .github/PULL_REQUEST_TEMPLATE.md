

# General
One line summary of PR
<!-- Examples:
- Adds tracking to the home section
- Fixes a crash when updating user records
- Implements password requirements as specified in [link]
-->

## Context
<!-- Example:
After the last update it became apparent that we did fetch the new results, but didn't actually store them properly. This caused a glitch in the UI whenever the user would refresh the screen and `onLoad` was invoked.
This PR updates the detection mechanism in `isUserActive` and propagates the changes to the UI properly.
-->

## Review / Testing
<!-- Examples:
- The authentication layer is fully covered by unit tests (see `tests/auth.c`), and I also added tests for the user model (`tests/usermodel.py`).
- As this code shuts down the host it is running on, it cannot be automatically tested. But I have successfully ran it in our test lab.
- This is a pure a UI change, I added a screenshot!
-->

# Checklist
## PR
<!-- Replace with ticket number -->
- [ ] JIRA ticket: https://gomimi.atlassian.net/browse/TICKET-000
- [ ] JIRA ticket number in PR title
- [ ] Reviewers tagged
- [ ] Number of reviewers: `NUMBER`
- [ ] Changelog updated

## Tests
- [ ] Unit tests added / updated
- [ ] Regression test added (for bugfix only)
- [ ] Integration test added / updated
- [ ] Tested manually
- [ ] Untestable / Not applicable

<!--
Check our Code Quality Guidelines:
https://gomimi.atlassian.net/wiki/spaces/MIMI/pages/1012137996/Mimi+Code+Quality+Guidelines
-->

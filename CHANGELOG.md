# Changelog

## 0.2.0

Caps and upgrades. A neutral Check can mean several things (allowance used,
payment attention, paid extras paused, hourly or daily cap); the agent reads
its title or `GET /v1/usage`, and shows an upgrade link only when
`pr.action` is not null. With an `aevr_` key already in the environment
(never collected in chat), the agent may read `GET /v1/usage` and show the
human the billing link an owner or admin opens. The agent never upgrades and
never opens the link itself. Prices are quoted only from the public plans
endpoint, never from memory (replaces the blanket no-prices rule).

## 0.1.0

First public portable adapter. Setup skill for the Aevral GitHub App. Reviews
run server-side. After App install, the next pull request can already be
reviewed, including before console claim.

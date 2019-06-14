# `/run/keys`

the switch command includes also everything
in `/run/keys` which can be populated using 
`populatedTmpfs` and can be accessed via `<keys/...>`

These keys will be gone after a restart of the machine.

There is a module which makes it easy to handle
theses tmpfs-keys.

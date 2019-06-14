## tmpfs

`plops` can populate your files and folders everywhere you want.
It comes with a function `populateTmpfs`
which populates the files and folders in `/run/plops-secrets/<name>`.
So these keys will be gone after a restart of the machine.

You can reference theses folder in your `configuration.nix`
like all the other sources.
For this example it would be `<secrets/my-secret-key>`.

There is a module which makes it easy to handle
systemd services depending on theses tmpfs files
(which are not present at boot time).

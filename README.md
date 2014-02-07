# BlockBlock

This is a plugin for MCServer that allows admins to specify blocks that players will not be able to place or break.

## Configuration

The plugin is configured through a `BlockedBlocks.ini` file in the MCServer's folder. The file contains a single section, `[General]`, with two settings. `ActiveWorlds` specifies the names of worlds where the blocking is active. If no world name is specified, all worlds are assumes. `Blocks` contains a comma-separated list of blocks that are blocked.
The blocks can be specified either by their numerical type, or by name. The block spec may contain an additional colon and a meta value; in such a case only the specified meta of the block will be blocked. Block names that translate into a specific meta (such as `redwool`) will also prevent only the specific meta.

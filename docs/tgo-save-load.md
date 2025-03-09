# Game State Persistance: Save & Load

- [Game State Persistance: Save \& Load](#game-state-persistance-save--load)
	- [Revision History](#revision-history)
- [SerializationManager](#serializationmanager)
	- [File Format / Structure](#file-format--structure)
	- [Working Directory](#working-directory)
		- [Level cache / working set](#level-cache--working-set)
		- [Saving](#saving)
		- [Loading](#loading)
- [Items & Equipment](#items-and-equipment)


## Revision History
- 2025-03-09 Added pointer to equipment/items note
- 2024-12-15 Initial incomplete snapshot

# SerializationManager

This is the highest level interface to saving and loading game. It exposes the
API we use to manage game state persistence:

- save_game
- load_game
- delete_save

Additionally it contions functions necessary to interact with saved levels:

- check_level_persistence
- update_level

All of these have docs with more details but we'll discuss them all at a high
level while covering the basic structure of how the save/load process works.

## File Format / Structure

At this point the save file is a zip file consistenting of:

- all visited levels as a PackedScene
- a dump of Dialogic state (taken by Dialogic and moved into place)
- a thumbnoil of the time of the save
- some metadata

During playtime that is all stored in `user://save` (or whatever is returned by
`Utils.user_save_dir()`).

When constructing a new save file we zip the contents of that directory into
`TGO.sav`.

## Working Directory
### Level cache / working set
While playing the game we cache level state on disk in directory
`Utils.user_data_dir()`. This is _primarily_ done when we unload a level but
conceptually could be used to checkpoint for some kind of rollback.

When Driver is loading a new level we first check for a version in cache and
then either load it or the unmodified version from the resource pack:

```python
	if _serialization_mgr.check_level_persistence(target_level_name):
		packed_level = load(_serialization_mgr.get_persistent_level_dict()[target_level_name])
	else:
		packed_level = load(Utils.level_to_path_text(target_level_name))
```

### Saving
As part of the save process we write the additional (non-level) data to this
same cache directory used for levels. This includes the metadata file, dialogic
state, etc.

Once that is all written we do the Zip and rename.

### Loading
Loading is pretty much an inverted save -- decompress a .sav into the working
directory and process the results.

For levels because we load on demand all we need to do is track which levels
were written out and mark those in our internal data structure to track them
as visited thereby using the cached version as described above.

For other data we actually need to load that back into the relevat systems.
With Dialogic for instance we copy the state files into its expected loaction
and instruct it to handle its own load (setup & error handling omited for
brevity):

```python
DirAccess.copy_absolute(
	Utils.user_save_dir().path_join(WORLD_STATE_FILE),
	Dialogic.Save.SAVE_SLOTS_DIR.path_join(DIALGOIC_SLOT).path_join(DIALOGIC_FILENAME),
)

Dialogic.Save.load(DIALGOIC_SLOT)
```

This tracks for other systems as well. Once it's all done we then emit a
`load_saved_level`.

When we begin loading a level we set `SerializationManager.is_loading_game`
to true and after emitting `load_saved_level` we set it to false.


# Items and Equipment

See PR where this was added: [#190](https://github.com/Small-Loan-Studio/TGO/pull/190).
class_name AK

class EVENTS:

	const PLAY_UI_NEWCLUE = 2507577916
	const PLAY_AM_CRYPT = 1814219829
	const PLAY_AM_CRYPT_RATSQUEAK = 401539735
	const PLAY_AM_CRYPT_RUBBLE = 2005530490
	const LEVELSTART = 3372421815
	const STOP_AM_CRYPT = 2908358191
	const PLAY_AM_CEMETERY = 2092297755
	const STOP_AM_CEMETERY = 2689129721
	const PLAY_IN_HARDTACK_EAT = 877166793
	const PLAY_UI_JOURNAL_TAB = 107540844
	const PLAY_IN_HARDTACK_PICKUP = 1652368853
	const PLAY_IN_JUNIPER_EAT = 427066036
	const PLAY_IN_JUNIPER_PICKUP = 1239768558
	const PLAY_IN_PAPERSCRAPS_PICKUP = 2395858153
	const PLAY_SKELETALREMAINS_SEARCH = 825345665
	const PLAY_PC_FOOSTEP = 3162604858
	const PLAY_TEST_TESTTONE = 3558576753
	const PLAY_TEST_TESTTONE_3D = 1671298337
	const PLAY_TEST_TESTTONE_LP = 882750264
	const PLAY_TEST_TESTTONE_LP_3D = 244812534
	const STOP_TEST_TESTTONE_LP = 1271341678
	const STOP_TEST_TESTTONE_LP_3D = 318226288
	const PLAY_UI_OPENINVENTORY = 677895889
	const PLAY_UI_QUESTLOG_OPEN = 973863878
	const PLAY_UI_NEWQUEST = 1783844251
	const PLAY_UI_QUESTCOMPLETED = 269604390

	const _dict = {
		"play_UI_NewClue": PLAY_UI_NEWCLUE,
		"play_AM_Crypt": PLAY_AM_CRYPT,
		"play_AM_Crypt_ratSqueak": PLAY_AM_CRYPT_RATSQUEAK,
		"play_AM_Crypt_rubble": PLAY_AM_CRYPT_RUBBLE,
		"LevelStart": LEVELSTART,
		"stop_AM_Crypt": STOP_AM_CRYPT,
		"play_AM_Cemetery": PLAY_AM_CEMETERY,
		"stop_AM_Cemetery": STOP_AM_CEMETERY,
		"play_IN_hardtack_eat": PLAY_IN_HARDTACK_EAT,
		"play_UI_Journal_tab": PLAY_UI_JOURNAL_TAB,
		"play_IN_hardtack_pickup": PLAY_IN_HARDTACK_PICKUP,
		"play_IN_juniper_eat": PLAY_IN_JUNIPER_EAT,
		"play_IN_juniper_pickup": PLAY_IN_JUNIPER_PICKUP,
		"play_IN_PaperScraps_pickup": PLAY_IN_PAPERSCRAPS_PICKUP,
		"play_SkeletalRemains_search": PLAY_SKELETALREMAINS_SEARCH,
		"play_PC_foostep": PLAY_PC_FOOSTEP,
		"play_TEST_TestTone": PLAY_TEST_TESTTONE,
		"play_TEST_TestTone_3D": PLAY_TEST_TESTTONE_3D,
		"play_TEST_TestTone_lp": PLAY_TEST_TESTTONE_LP,
		"play_TEST_TestTone_lp_3D": PLAY_TEST_TESTTONE_LP_3D,
		"stop_TEST_TestTone_lp": STOP_TEST_TESTTONE_LP,
		"stop_TEST_TestTone_lp_3D": STOP_TEST_TESTTONE_LP_3D,
		"play_UI_OpenInventory": PLAY_UI_OPENINVENTORY,
		"play_UI_QuestLog_open": PLAY_UI_QUESTLOG_OPEN,
		"play_UI_NewQuest": PLAY_UI_NEWQUEST,
		"play_UI_QuestCompleted": PLAY_UI_QUESTCOMPLETED
	}

class STATES:

	class GAMESTATE:
		const GROUP = 4091656514

		class STATE:
			const NONE = 748895195
			const INGAME = 984691642
			const INMENU = 3374585465

	class PLAYERSTATE:
		const GROUP = 3285234865

		class STATE:
			const NONE = 748895195
			const ALIVE = 655265632
			const DEAD = 2044049779

	const _dict = {
		"GameState": {
			"GROUP": 4091656514,
			"STATE": {
				"None": 748895195,
				"InGame": 984691642,
				"InMenu": 3374585465,
			}
		},
		"PlayerState": {
			"GROUP": 3285234865,
			"STATE": {
				"None": 748895195,
				"Alive": 655265632,
				"Dead": 2044049779
			}
		}
	}

class SWITCHES:

	class REALMSWITCH:
		const GROUP = 1315705422

		class SWITCH:
			const ETHEREALREALM = 700741848
			const REALITY = 3568254687

	class AMBIENCEAREASWITCH:
		const GROUP = 1059039322

		class SWITCH:
			const CEMETERY = 1829412849
			const CRYPT = 2761606855
			const MANORHOUSE = 2487661812
			const OAKSHAWEXT = 4241827858
			const OAKSHAWINT = 246886364

	class BLACKMISTSWITCH:
		const GROUP = 3010276917

		class SWITCH:
			const MIST = 3062523246
			const NOMIST = 2671368699

	class TIMEOFDAYSWITCH:
		const GROUP = 2079479385

		class SWITCH:
			const DAWNDUSK = 954352572
			const DAY = 311764537
			const NIGHT = 1011622525

	class COMBATSWITCH:
		const GROUP = 637647069

		class SWITCH:
			const BOSS = 1560169506
			const COMBAT = 2764240573
			const EXPLORE = 579523862

	class GROUNDMATERIALSWITCH:
		const GROUP = 1044534455

		class SWITCH:
			const DIRT = 2195636714
			const GRASS = 4248645337
			const GRAVEL = 2185786256
			const PAVEMENT = 2830102203
			const STONE = 1216965916
			const WOOD = 2058049674

	class PLAYERHEALTHSWITCH:
		const GROUP = 206614296

		class SWITCH:
			const DAMAGEDHEALTH = 3144424692
			const FULLHEALTH = 2429688720
			const LOWHEALTH = 1017222595
			const NOHEALTH = 2921131014

	const _dict = {
		"RealmSwitch": {
			"GROUP": 1315705422,
			"SWITCH": {
				"EtherealRealm": 700741848,
				"Reality": 3568254687,
			}
		},
		"AmbienceAreaSwitch": {
			"GROUP": 1059039322,
			"SWITCH": {
				"Cemetery": 1829412849,
				"Crypt": 2761606855,
				"ManorHouse": 2487661812,
				"OakshawExt": 4241827858,
				"OakshawInt": 246886364,
			}
		},
		"BlackMistSwitch": {
			"GROUP": 3010276917,
			"SWITCH": {
				"Mist": 3062523246,
				"NoMist": 2671368699,
			}
		},
		"TimeOfDaySwitch": {
			"GROUP": 2079479385,
			"SWITCH": {
				"DawnDusk": 954352572,
				"Day": 311764537,
				"Night": 1011622525,
			}
		},
		"CombatSwitch": {
			"GROUP": 637647069,
			"SWITCH": {
				"Boss": 1560169506,
				"Combat": 2764240573,
				"Explore": 579523862,
			}
		},
		"GroundMaterialSwitch": {
			"GROUP": 1044534455,
			"SWITCH": {
				"Dirt": 2195636714,
				"Grass": 4248645337,
				"Gravel": 2185786256,
				"Pavement": 2830102203,
				"Stone": 1216965916,
				"Wood": 2058049674,
			}
		},
		"PlayerHealthSwitch": {
			"GROUP": 206614296,
			"SWITCH": {
				"DamagedHealth": 3144424692,
				"FullHealth": 2429688720,
				"LowHealth": 1017222595,
				"NoHealth": 2921131014
			}
		}
	}

class GAME_PARAMETERS:

	const MUSICVOL_RTPC = 2214243713
	const SFXVOL_RTPC = 411284441
	const MASTERVOL_RTPC = 571276072
	const DISTANCE_RTPC = 1273457242
	const PLAYERHEALTH_RTPC = 3204359326
	const TIMEOFDAY_RTPC = 3067665661

	const _dict = {
		"MusicVol_RTPC": MUSICVOL_RTPC,
		"SFXVol_RTPC": SFXVOL_RTPC,
		"MasterVol_RTPC": MASTERVOL_RTPC,
		"Distance_RTPC": DISTANCE_RTPC,
		"PlayerHealth_RTPC": PLAYERHEALTH_RTPC,
		"TimeOfDay_RTPC": TIMEOFDAY_RTPC
	}

class TRIGGERS:

	const WALKING = 340271938
	const LEVELSTART = 3372421815

	const _dict = {
		"Walking": WALKING,
		"LevelStart": LEVELSTART
	}

class BANKS:

	const INIT = 1355168291
	const MAIN = 3161908922

	const _dict = {
		"Init": INIT,
		"Main": MAIN
	}

class BUSSES:

	const MASTER = 4056684167
	const MUSIC = 3991942870
	const SFX = 393239870
	const AMBIENCE = 85412153
	const AMBIENCE2D = 98821071
	const AMBIENCE3D = 82043516
	const AMBIENCEBEDS = 1834684777
	const ENEMIES = 2242381963
	const ENEMYABILITIES = 3904002455
	const ENEMYMOVEMENT = 223964144
	const INTERACTABLES = 181270742
	const NPC = 662417162
	const NPCABILITIES = 4241445800
	const NPCMOVEMENT = 917094613
	const PLAYER = 1069431850
	const PLAYERABILITIES = 466672200
	const PLAYERMOVEMENT = 1350496757
	const USERINTERFACE = 1858488437
	const DIALOG = 1235749641
	const EVENTS = 1381315342

	const _dict = {
		"MASTER": MASTER,
		"MUSIC": MUSIC,
		"SFX": SFX,
		"Ambience": AMBIENCE,
		"Ambience2D": AMBIENCE2D,
		"Ambience3D": AMBIENCE3D,
		"AmbienceBeds": AMBIENCEBEDS,
		"Enemies": ENEMIES,
		"EnemyAbilities": ENEMYABILITIES,
		"EnemyMovement": ENEMYMOVEMENT,
		"Interactables": INTERACTABLES,
		"NPC": NPC,
		"NPCAbilities": NPCABILITIES,
		"NPCMovement": NPCMOVEMENT,
		"Player": PLAYER,
		"PlayerAbilities": PLAYERABILITIES,
		"PlayerMovement": PLAYERMOVEMENT,
		"UserInterface": USERINTERFACE,
		"Dialog": DIALOG,
		"Events": EVENTS
	}

class AUX_BUSSES:

	const REVERBS = 3545700988
	const CEMETERY = 1829412849
	const CRYPT = 2761606855
	const OAKSHAWEXT = 4241827858
	const OAKSHAWINT = 246886364

	const _dict = {
		"Reverbs": REVERBS,
		"Cemetery": CEMETERY,
		"Crypt": CRYPT,
		"OakshawExt": OAKSHAWEXT,
		"OakshawInt": OAKSHAWINT
	}

class AUDIO_DEVICES:

	const NO_OUTPUT = 2317455096
	const SYSTEM = 3859886410

	const _dict = {
		"No_Output": NO_OUTPUT,
		"System": SYSTEM
	}

class EXTERNAL_SOURCES:

	const _dict = {}


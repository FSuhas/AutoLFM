--------------------------------------------------
-- States - Runtime Variables
--------------------------------------------------

--------------------------------------------------
-- Character Information
--------------------------------------------------
playerCharacterName = nil
playerRealmName = nil
characterUniqueID = nil

--------------------------------------------------
-- Broadcast State
--------------------------------------------------
isBroadcastActive = false
broadcastStartTimestamp = 0
lastBroadcastTimestamp = 0
broadcastMessageCount = 0
groupSearchStartTimestamp = 0

--------------------------------------------------
-- User Selections
--------------------------------------------------
selectedDungeonTags = {}
selectedRaidTags = {}
selectedRolesList = {}
selectedChannelsList = {}

--------------------------------------------------
-- Messages
--------------------------------------------------
generatedLFMMessage = ""
customUserMessage = ""
raidGroupSize = 0
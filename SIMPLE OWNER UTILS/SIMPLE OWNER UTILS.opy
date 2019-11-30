#Global variables

#!declareGlobal B_ShowWelcomeMessage 0
#!declareGlobal B_ShowOperatorInfoHUD 1
#!declareGlobal B_OperatorEnabled 2
#!declareGlobal V_GameTime 4
#!declareGlobal B_FriendlyModeEnabled 6
#!declareGlobal B_TeleportEnabled 10


#Player variables

#!declarePlayer B_HasOperatorRights 0
#!declarePlayer B_IsInOperatorMode 1
#!declarePlayer I_CurrentActionID 2
#!declarePlayer B_CreateNewHUD 3
#!declarePlayer HUD_CurrentOperatorHUD 4
#!declarePlayer B_WelcomeMessageSeen 5
#!declarePlayer B_IsInThirdPerson 6
#!declarePlayer B_IsPhasedOut 8
#!declarePlayer HUD_ModeratorSideHUD 12
#!declarePlayer B_IsAFK 13
#!declarePlayer B_InFriendlyMode 14
#!declarePlayer I_FriendlyModeCooldown 15
#!declarePlayer B_IsInvisible 16
#!declarePlayer B_IsControllingPlayer 17
#!declarePlayer P_ControlledPlayer 18
#!declarePlayer B_IsModerator 19
#!declarePlayer Eff_TargetEffect 22
#!declarePlayer Y_FacingVar 24


@Rule "SETTINGS Match time"
@Event global
V_GameTime = 30


@Rule "SETTINGS Teleport"
@Event global
B_TeleportEnabled = false


@Rule "GLOBAL Set Match Time"
@Event global
setMatchTime(V_GameTime * 60)


@Rule "GLOBAL Teleport (ROSTYAGT)"
@Event eachPlayer
if B_TeleportEnabled and eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.CROUCH) and not eventPlayer.isDead() and not eventPlayer.hasStatusEffect(Status.HACKED) and not eventPlayer.hasStatusEffect(Status.FROZEN) and not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) and not eventPlayer.hasStatusEffect(Status.ASLEEP) and not eventPlayer.isCommunicatingEmote():
    eventPlayer.Y_FacingVar = eventPlayer.getFacingDirection()
    eventPlayer.teleport(eventPlayer.getPosition() + eventPlayer.getFacingDirection() * 12.5)
    eventPlayer.setFacing(eventPlayer.Y_FacingVar, Relativity.TO_WORLD)
    eventPlayer.applyImpulse(Vector.UP, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.75)


@Rule "GLOBAL Disable game completion and announcer (ROSTYAGT)"
@Event global
disableAnnouncer()
disableGamemodeCompletion()


@Rule "GLOBAL Declare match draw (ROSTYAGT)"
@Event global
if getMatchTime() == 0:
    declareDraw


@Rule "GLOBAL Welcome Message"
@Event eachPlayer
if not eventPlayer.B_WelcomeMessageSeen and eventPlayer.hasSpawned():
    wait(2)
    bigMessage(eventPlayer, l"Welcome {}".format(eventPlayer))
    wait(1.5)
    smallMessage(eventPlayer, "Hold CTRL + SPACE + F to change view")
    eventPlayer.B_WelcomeMessageSeen = true


@Rule "GLOBAL Game operator HUD"
@Event global
if true:
    hudText(getAllPlayers(), null, "Game operator", l"{} {}".format(heroIcon(hostPlayer.getCurrentHero()), hostPlayer), Position.RIGHT, 0, Color.WHITE, Color.ORANGE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


@Rule "OPERATOR Give operator to host player"
@Event eachPlayer
if eventPlayer == hostPlayer:
    eventPlayer.B_HasOperatorRights = true


@Rule "OPERATOR Enter operator mode"
@Event eachPlayer
if eventPlayer.B_HasOperatorRights and eventPlayer.isHoldingButton(Button.CROUCH) and not eventPlayer.isHoldingButton(Button.JUMP):
    eventPlayer.B_IsInOperatorMode = true
    eventPlayer.B_CreateNewHUD = true
    wait(0.8, Wait.ABORT_WHEN_FALSE)


@Rule "OPERATOR Leave operator mode"
@Event eachPlayer
if eventPlayer.B_HasOperatorRights and not eventPlayer.isHoldingButton(Button.CROUCH):
    eventPlayer.B_IsInOperatorMode = false
    destroyHudText(eventPlayer.HUD_CurrentOperatorHUD)


@Rule "OPERATOR Switch actions"
@Event eachPlayer
if eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.JUMP):
    eventPlayer.I_CurrentActionID++
    eventPlayer.B_CreateNewHUD = true


@Rule "OPERATOR Disable abilities in operator mode"
@Event eachPlayer
if eventPlayer.B_IsInOperatorMode and eventPlayer.I_CurrentActionID != 0:
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)


@Rule "OPERATOR Enable abilities"
@Event eachPlayer
if not eventPlayer.B_IsInOperatorMode:
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    destroyEffect(eventPlayer.Eff_TargetEffect)


@Rule "OPERATOR Operator mode HUD I"
@Event eachPlayer
if eventPlayer.B_IsInOperatorMode and eventPlayer.B_CreateNewHUD and eventPlayer.I_CurrentActionID <= 6:
    destroyHudText(eventPlayer.HUD_CurrentOperatorHUD)
    if eventPlayer.I_CurrentActionID != 0:
        goto lbl_0
    hudText(eventPlayer, "Action: Null", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_0:
    if eventPlayer.I_CurrentActionID != 1:
        goto lbl_1
    hudText(eventPlayer, "Action: Kill / Heal", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_1:
    if eventPlayer.I_CurrentActionID != 2:
        goto lbl_2
    hudText(eventPlayer, "Action: Teleport", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_2:
    if eventPlayer.I_CurrentActionID != 3:
        goto lbl_3
    hudText(eventPlayer, "Action: Freeze", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_3:
    if eventPlayer.I_CurrentActionID != 4:
        goto lbl_4
    hudText(eventPlayer, "Action: Phase out", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_4:
    if eventPlayer.I_CurrentActionID != 5:
        goto lbl_5
    hudText(eventPlayer, "Action: Knock down", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_5:
    if eventPlayer.I_CurrentActionID != 6:
        goto lbl_6
    hudText(eventPlayer, "Action: Hack", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_6:
    eventPlayer.B_CreateNewHUD = false


@Rule "OPERATOR Operator mode HUD II"
@Event eachPlayer
if eventPlayer.B_IsInOperatorMode and eventPlayer.B_CreateNewHUD and eventPlayer.I_CurrentActionID > 6:
    destroyHudText(eventPlayer.HUD_CurrentOperatorHUD)
    if eventPlayer.I_CurrentActionID != 7:
        goto lbl_0
    hudText(eventPlayer, "Action: Control player", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_0:
    if eventPlayer.I_CurrentActionID != 8:
        goto lbl_1
    hudText(eventPlayer, "Action: Slow Motion", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_1:
    if eventPlayer.I_CurrentActionID != 9:
        goto lbl_2
    hudText(eventPlayer, "Action: Invisibility", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_2:
    if eventPlayer.I_CurrentActionID != 10:
        goto lbl_3
    hudText(eventPlayer, "Action: Give OP Rights", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()
    lbl_3:
    eventPlayer.B_CreateNewHUD = false


@Rule "OPERATOR Loop mode ID"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 11:
    eventPlayer.I_CurrentActionID = 0
    hudText(eventPlayer, "Action: Null", "Action ID", eventPlayer.I_CurrentActionID, Position.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.HUD_CurrentOperatorHUD = getLastCreatedText()


@Rule "OPERATOR Target HUD"
@Event eachPlayer
hudText([i for i in eventPlayer if eventPlayer.B_IsInOperatorMode], l"{} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL)), "Health", l"{}%".format(100 * eventPlayer.getPlayerClosestToReticle(Team.ALL).getNormalizedHealth()), Position.LEFT, 2, Color.SKY_BLUE, Color.RED, Color.RED, HudReeval.VISIBILITY_AND_STRING)


@Rule "OPERATOR Players Indicators"
@Event eachPlayer
createInWorldText([player for player in getAllPlayers() if player.B_IsInOperatorMode], l"{}: {}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer), eventPlayer.getPosition() + vect(0, 2.8, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)


@Rule "OPERATOR Target Effect"
@Event eachPlayer
if eventPlayer.B_IsInOperatorMode:
    createEffect([i for i in eventPlayer if eventPlayer.B_IsInOperatorMode], Effect.GOOD_AURA, Color.ORANGE, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.Eff_TargetEffect = getLastCreatedEntity()


@Rule "CAMERA Default 3rd person"
@Event eachPlayer
eventPlayer.setCamera(eventPlayer + worldVector(vect(0, 0.399, -0.7), eventPlayer, Transform.ROTATION) + Vector.UP * 1.5 + eventPlayer.getFacingDirection() * -2.25, eventPlayer + eventPlayer.getFacingDirection() * 100, 70)
eventPlayer.B_IsInThirdPerson = true


@Rule "CAMERA Toggle 1rd person"
@Event eachPlayer
if eventPlayer.B_IsInThirdPerson and eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH):
    wait(0.3, Wait.ABORT_WHEN_FALSE)
    eventPlayer.stopCamera()
    eventPlayer.B_IsInThirdPerson = false


@Rule "CAMERA Toggle 3rd person"
@Event eachPlayer
if not eventPlayer.B_IsInThirdPerson and eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.JUMP):
    wait(0.3, Wait.ABORT_WHEN_FALSE)
    eventPlayer.setCamera(eventPlayer + worldVector(vect(0, 0.399, -0.7), eventPlayer, Transform.ROTATION) + Vector.UP * 1.5 + eventPlayer.getFacingDirection() * -2.25, eventPlayer + eventPlayer.getFacingDirection() * 100, 70)
    eventPlayer.B_IsInThirdPerson = true


@Rule "MODES [1] Kill target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    kill(eventPlayer.getPlayerClosestToReticle(Team.ALL), eventPlayer)


@Rule "MODES [1] Kill all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_2):
    playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    kill(getAllPlayers(), eventPlayer)


@Rule "MODES [1] Heal target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.YELLOW, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).resurrect()
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "has been healed"))


@Rule "MODES [1] Heal all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, eventPlayer, 3)
    for player in getAllPlayers():
        player.resurrect()


@Rule "MODES [1] Kill self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isAlive():
    eventPlayer.setDamageReceived(100)
    wait(0.2, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
    kill(eventPlayer, eventPlayer)


@Rule "MODES [1] Heal self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 1 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isDead():
    wait(0.2, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.YELLOW, eventPlayer, 1)
    eventPlayer.resurrect()


@Rule "MODES [2] Teleport to target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 2 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.RED, eventPlayer, 80)
    eventPlayer.teleport(eventPlayer.getPlayerClosestToReticle(Team.ALL))
    smallMessage(eventPlayer, l"{} {}".format("Teleported to", eventPlayer.getPlayerClosestToReticle(Team.ALL)))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), l"{} {}".format(eventPlayer, "teleported to you"))


@Rule "MODES [2] Teleport target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 2 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 80)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).teleport(eventPlayer)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).resurrect()
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "teleported"))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), l"{} {}".format(eventPlayer, "teleported you"))


@Rule "MODES [2] Teleport all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 2 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, eventPlayer, 3)
    for player in getAllPlayers():
        player.teleport(eventPlayer)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 160)
    smallMessage(eventPlayer, "All players teleported")
    smallMessage(getAllPlayers(), l"{} {}".format(eventPlayer, "teleported you"))


@Rule "MODES [3] Freeze target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setStatusEffect(eventPlayer, Status.FROZEN, 9999)
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "has been frozen"))


@Rule "MODES [3] Unfreeze target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).clearStatusEffect(Status.FROZEN)


@Rule "MODES [3] Freeze all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, eventPlayer, 3)
    getAllPlayers().exclude(eventPlayer).setStatusEffect(eventPlayer, Status.FROZEN, 9999)
    smallMessage(eventPlayer, "All players have been frozen")


@Rule "MODES [3] Unfreeze all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_2):
    for player in getAllPlayers():
        player.clearStatusEffect(Status.FROZEN)


@Rule "MODES [3] Freeze self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and not eventPlayer.hasStatusEffect(Status.FROZEN):
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer, 1)
    eventPlayer.setStatusEffect(eventPlayer, Status.FROZEN, 9999)
    smallMessage(eventPlayer, "You have been frozen")


@Rule "MODES [3] Unfreeze self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 3 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.hasStatusEffect(Status.FROZEN):
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer, 1)
    eventPlayer.clearStatusEffect(Status.FROZEN)


@Rule "MODES [4] Phase out target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 4 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsPhasedOut and not eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsAFK:
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.PURPLE, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setStatusEffect(eventPlayer, Status.PHASED_OUT, 9999)
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "is now phased out"))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), l"{} {}".format(eventPlayer, "made you phased out"))
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsPhasedOut = true


@Rule "MODES [4] Remove phase out target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 4 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsPhasedOut:
    eventPlayer.getPlayerClosestToReticle(Team.ALL).clearStatusEffect(Status.PHASED_OUT)
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "is no longer phased out"))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), "You are no longer phased out")
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsPhasedOut = false


@Rule "MODES [4] Phase out self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 4 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and not eventPlayer.B_IsAFK:
    wait(0.35, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.PURPLE, eventPlayer, 1)
    eventPlayer.setStatusEffect(eventPlayer, Status.PHASED_OUT, 9999)
    smallMessage(eventPlayer, "You are now phased out")


@Rule "MODES [4] Remove phase out self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 4 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.hasStatusEffect(Status.PHASED_OUT):
    wait(0.35, Wait.ABORT_WHEN_FALSE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)


@Rule "MODES [5] Knock target down"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 9999)
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "has been knocked down"))


@Rule "MODES [5] Undo knock down target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).clearStatusEffect(Status.KNOCKED_DOWN)


@Rule "MODES [5] Knock all players down"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, eventPlayer, 3)
    getAllPlayers().exclude(eventPlayer).setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 9999)
    smallMessage(eventPlayer, "All players have been knocked down")


@Rule "MODES [5] Undo knock all players down"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_2):
    for player in getAllPlayers():
        player.clearStatusEffect(Status.KNOCKED_DOWN)


@Rule "MODES [5] Knock down self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN):
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer, 1)
    eventPlayer.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 9999)
    smallMessage(eventPlayer, "You have been knocked down")


@Rule "MODES [5] Undo knock down self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 5 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN):
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer, 1)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)


@Rule "MODES [6] Hack target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 6 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setStatusEffect(eventPlayer, Status.HACKED, 9999)
    smallMessage(eventPlayer, l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "has been hacked"))


@Rule "MODES [6] Unhack target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 6 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer.getPlayerClosestToReticle(Team.ALL), 1)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).clearStatusEffect(Status.HACKED)


@Rule "MODES [6] Hack all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 6 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, eventPlayer, 3)
    getAllPlayers().exclude(eventPlayer).setStatusEffect(eventPlayer, Status.HACKED, 9999)
    smallMessage(eventPlayer, "All players have been hacked")


@Rule "MODES [6] Unhack all"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 6 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_2):
    for player in getAllPlayers():
        player.clearStatusEffect(Status.HACKED)


@Rule "MODES [6] Hack Self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 6 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE):
    smallMessage(eventPlayer, "You cannot hack yourself")


@Rule "MODES [7] Control Taget On"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 7 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.B_IsControllingPlayer:
    eventPlayer.P_ControlledPlayer = eventPlayer.getPlayerClosestToReticle(Team.ALL)
    eventPlayer.B_IsControllingPlayer = true


@Rule "MODES [7] Control Taget Off"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 7 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.B_IsControllingPlayer:
    eventPlayer.B_IsControllingPlayer = false


@Rule "MODES [7] Launch Taget"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 7 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.B_IsControllingPlayer:
    eventPlayer.B_IsControllingPlayer = false
    eventPlayer.P_ControlledPlayer.applyImpulse(eventPlayer.getFacingDirection(), 50, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


@Rule "GLOBAL Control Players [GENERATES LAGS]"
@Event eachPlayer
if eventPlayer.B_IsControllingPlayer:
    do:
        if not RULE_CONDITION:
            return
        wait(0.02)
        eventPlayer.P_ControlledPlayer.teleport(worldVector(vect(eventPlayer.x, (eventPlayer.getVerticalFacingAngle() - eventPlayer.getVerticalFacingAngle() * 2) / 10, eventPlayer.z + 5), eventPlayer, Transform.ROTATION_AND_TRANSLATION))
    while RULE_CONDITION


@Rule "MODES [8] Slow motion on"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 8 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_1):
    bigMessage(getAllPlayers(), "Slow motion enabled")
    setSlowMotion(50)


@Rule "MODES [8] Slow motion off"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 8 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ABILITY_2):
    bigMessage(getAllPlayers(), "Slow motion disabled")
    setSlowMotion(100)


@Rule "MODES [9] Invisibility target"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 9 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    if eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsInvisible:
        goto lbl_0
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setInvisibility(Invis.ALL)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsInvisible = true
    smallMessage([player for player in getAllPlayers() if eventPlayer.B_HasOperatorRights], l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "is now invisible"))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), l"{} {}".format(eventPlayer, "made you invisible"))
    return
    lbl_0:
    if not eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsInvisible:
        goto lbl_1
    eventPlayer.getPlayerClosestToReticle(Team.ALL).setInvisibility(Invis.NONE)
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsInvisible = false
    smallMessage([player for player in getAllPlayers() if eventPlayer.B_HasOperatorRights], l"{} {} {}".format(heroIcon(eventPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()), eventPlayer.getPlayerClosestToReticle(Team.ALL), "is no longer invisible"))
    smallMessage(eventPlayer.getPlayerClosestToReticle(Team.ALL), l"{} {}".format(eventPlayer, "made you visible"))
    lbl_1:


@Rule "MODES [9] Invisibility self"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 9 and eventPlayer.B_IsInOperatorMode and eventPlayer.isHoldingButton(Button.ULTIMATE):
    if eventPlayer.B_IsInvisible:
        goto lbl_0
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.B_IsInvisible = true
    return
    lbl_0:
    if not eventPlayer.B_IsInvisible:
        goto lbl_1
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.B_IsInvisible = false
    lbl_1:


@Rule "GLOBAL Infinite ultimates"
@Event eachPlayer
if eventPlayer.getUltCharge() != 100 and eventPlayer.hasSpawned() and eventPlayer.B_HasOperatorRights:
    eventPlayer.setUltCharge(100)


@Rule "MODES [10] Give operator rights"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 10 and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer == hostPlayer and eventPlayer.B_IsInOperatorMode:
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_HasOperatorRights = true
    smallMessage(eventPlayer, l"{} {}".format(eventPlayer.getPlayerClosestToReticle(Team.ALL), "received operator powers"))
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsModerator = true


@Rule "MODES [10] Remove operator rights"
@Event eachPlayer
if eventPlayer.I_CurrentActionID == 10 and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer == hostPlayer and eventPlayer.getPlayerClosestToReticle(Team.ALL).B_HasOperatorRights and eventPlayer.B_IsInOperatorMode:
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_HasOperatorRights = false
    smallMessage(eventPlayer, l"{} {}".format(eventPlayer.getPlayerClosestToReticle(Team.ALL), "lost operator powers"))
    eventPlayer.getPlayerClosestToReticle(Team.ALL).B_IsModerator = false
    destroyHudText(eventPlayer.getPlayerClosestToReticle(Team.ALL).HUD_ModeratorSideHUD)


@Rule "CAMERA Junkrat fix  (ROSTYAGT)"
@Event eachPlayer
if getPlayersOnHero(Hero.JUNKRAT, Team.ALL) and eventPlayer.isUsingUltimate():
    eventPlayer.stopCamera()



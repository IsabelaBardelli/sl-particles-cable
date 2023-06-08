// final
integer DEFAULT_HIDDEN_CHANNEL = 666;
string PSYS_SRC_TEXTURE_KEY = "d7e43026-c096-4321-4e3b-17d19fd0a83e";

// logic
integer att = FALSE;
string connKey = "";

// listener
integer connectorListener;

// llEvent
list particleParameters = [];

start_particles() {
    particleParameters = [
        // Texture Parameters:
        PSYS_SRC_TEXTURE, (key) PSYS_SRC_TEXTURE_KEY,
        PSYS_PART_START_SCALE, < .05, .05, FALSE > ,
        PSYS_PART_END_SCALE, < .05, .04, FALSE > ,
        PSYS_PART_START_COLOR, < 0, 0, 0.2 > ,
        PSYS_PART_END_COLOR, < 0.0, 0.0, 1.0 > ,
        PSYS_PART_START_ALPHA, (float) 1, PSYS_PART_END_ALPHA, (float) 0,
        PSYS_PART_START_GLOW, 0, PSYS_PART_END_GLOW, 0.1,

        // Production Parameters:
        PSYS_SRC_BURST_PART_COUNT, (integer) 1,
        PSYS_SRC_BURST_RATE, (float) 0.03,
        PSYS_PART_MAX_AGE, (float) 5.0,
        PSYS_SRC_MAX_AGE, (float) .0,

        // Placement Parameters:
        PSYS_SRC_PATTERN, (integer) 1,

        // Placement Parameters (for any non-DROP pattern):
        PSYS_SRC_BURST_RADIUS, 1.0,

        // After-Effect & Influence Parameters:
        PSYS_SRC_ACCEL, < 0.0, 0.0, -.5 > ,
        PSYS_PART_FLAGS, (integer)(0 | PSYS_PART_INTERP_SCALE_MASK |
            PSYS_PART_EMISSIVE_MASK | PSYS_PART_RIBBON_MASK | PSYS_PART_TARGET_POS_MASK
        ),
        PSYS_SRC_TARGET_KEY, (key) connKey
    ];

    llParticleSystem(particleParameters);
}

stop_particles() {
    llParticleSystem([]);
}

change_listener(integer listener, string cKey) {
    llListenRemove(listener);
    connectorListener = llListen(DEFAULT_HIDDEN_CHANNEL, "", (key) cKey, "");
}

// Listens to needed resource only
process_click(integer att, key cKey) {
    if (att) {
        stop_particles();
        llSleep(.3);
        start_particles();
        change_listener(connectorListener, cKey);
    } else {
        stop_particles();
        llSleep(.3);
        change_listener(connectorListener, NULL_KEY);
    }
}

default {
    state_entry() {
        llOwnerSay("[Re]loading " + llGetObjectName());
        stop_particles();

        // Open listener is laggy (NULL_KEY) but needed if unatted
        connectorListener = llListen(DEFAULT_HIDDEN_CHANNEL, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message) {
        message = llStringTrim(message, STRING_TRIM);

        if (message == connKey) att = !att;
        else {
            connKey = message;
            att = TRUE;
        }
        process_click(att, connKey);
    }
}

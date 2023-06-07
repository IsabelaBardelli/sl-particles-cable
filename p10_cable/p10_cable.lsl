integer DEFAULT_HIDDEN_CHANNEL = 666;
integer running = FALSE; 

list particleParameters = []; 

integer listenP10;
integer listenOwner;

string plugKey = "";

start_particles() 
{
    particleParameters = [ 
        // Texture Parameters:
        PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0),
        PSYS_PART_START_SCALE, <.05, .05, FALSE > ,
        PSYS_PART_END_SCALE, <.05, .04, FALSE > ,
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
        PSYS_SRC_PATTERN, (integer) 1, // 1=DROP, 2=EXPLODE, 4=ANGLE, 8=ANGLE_CONE,
        // Placement Parameters (for any non-DROP pattern):
        // PSYS_SRC_BURST_SPEED_MIN, (float)1.0,                  
        //PSYS_SRC_BURST_SPEED_MAX, (float)2.0, 
        PSYS_SRC_BURST_RADIUS, 1.0,
        // Placement Parameters (only for ANGLE & CONE patterns):
        // PSYS_SRC_ANGLE_BEGIN, (float) .5 * PI, PSYS_SRC_ANGLE_END, (float) 0.0 * PI,
        // PSYS_SRC_OMEGA, <0,0,0>, 
        // After-Effect & Influence Parameters:
        PSYS_SRC_ACCEL, < 0.0, 0.0, -.5 > ,     
        PSYS_PART_FLAGS, (integer)(0 | PSYS_PART_INTERP_SCALE_MASK |
            PSYS_PART_EMISSIVE_MASK | PSYS_PART_RIBBON_MASK | PSYS_PART_TARGET_POS_MASK
        ),
        PSYS_SRC_TARGET_KEY, (key) plugKey               
    ];

    llParticleSystem(particleParameters);
}

stop_particles() 
{
    llParticleSystem([]);
}

link_to_single_p10(integer p10, string pKey) {
    llListenRemove(p10);
    listenP10 = llListen(DEFAULT_HIDDEN_CHANNEL, "", pKey, "");

    llOwnerSay("Now the connector is linked to this p10, use '/666 reset' to reset.");
}

default {
    state_entry() {
        llOwnerSay("[Re]loading " + llGetObjectName());
        stop_particles();

        // Listen to everyone is laggy (NULL_KEY)
        listenP10 = llListen(DEFAULT_HIDDEN_CHANNEL, "", NULL_KEY, "");
        listenOwner = llListen(DEFAULT_HIDDEN_CHANNEL, "", llGetOwner(), "");
    }

    listen(integer channel, string name, key id, string message)
    {    
        message = llStringTrim(message, STRING_TRIM);

        if (id == llGetOwner()) {
            if (message == "reset") llResetScript();
        } else {
            if (message == plugKey) {
                running = !running;
            } else {
                plugKey = message;
                running = TRUE;
            }
            
            if (running) {
                stop_particles();
                llSleep(.3);
                start_particles();
            } else {
                stop_particles();
            }

            link_to_single_p10(listenP10, plugKey);
        }
    }
}


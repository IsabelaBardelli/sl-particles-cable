integer DEFAULT_HIDDEN_CHANNEL = 666;

default
{
    state_entry()
    {
        llOwnerSay("[Re]loading " + llGetObjectName());
    }

    touch_start(integer total_number)
    {
        llWhisper(DEFAULT_HIDDEN_CHANNEL, llGetKey());
    }
}



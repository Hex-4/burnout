# burnout (the prototype)

hi! i've had this dream game bouncing around in my head for forever. i think grapple games are really cool and there should be more games dedicated to that "flow state" where you're soaring between anchors and perfectly executing every movement and arc. i'm also a huge celeste fan and i love how tight, responsive, and juicy that game feels. so the vision for burnout is something like "celeste but it's a grapple not a dash".

this prototype... does not have a celeste level of polish. but it does have a player, and it does have a grapple!

play it on [itch.io](https://serialquest.itch.io/burnout-prototype).

A / D to move, Space to jump, mouse to aim, left click to grapple. hold space while grappling to reel yourself in.

![image](https://cdn.hackclub.com/01a0a327-b972-76ab-a3cd-f3f4d78565b2/image.png)

## how it was made

godot and aseprite! my usual stack! standard 2d player controller. we watch grapple points around the player and score them based on closeness and angle to the mouse. on click we pick the best one and constrain the player to a circle around it. that's pretty much how the grapple works! to get the flying and soaring aspect, just adding a way for a player to shrink the radius of the circle (reeling in with Space) will speed up the player, shooting them out when they release.

## hack on it

i don't know why you would want to look at my horrible code, but this is just a godot project! clone it and open it in godot 4.7. if you want. i don't recommend it

## ai usage

ai helped a lot with the maths for the grapple mechanic and general advice. it wrote some expressions used in the code but no actual lines of code were copy pasted :)

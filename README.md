# nix-macOS
Declarative and idempotent configuration of macOS with my settings, using Nix.

## The Importance of Reproducibility
Many systems are manually set up over months, even years with no documentation. If a system was damaged either physically of with a bad software update, it would be difficult to get the same setup in a reasonable time. With tools such as Nix, all I would have to do is install Nix, download this repo, and install it. That's it. Three commands and I can start being productive again.

## My Motivation
Putting all of your settings down in a list and getting over the learning curve for Nix can be a pain, which is why I put this off for so long. What finally got me to make this was a bad OS update. macOS 15.0, the current version at the time of writing, has a bug that has been preventing me from being productive. When using ssh, my sessions kept getting killed because of bad packet lengths. After reading online forums and trying to solve it, I believe the only solution is to reinstall an earlier version of macOS. I therefore need to itemize everything I have done to setup my system in the case I accidentally delete everything. So why not learn Nix along the way?

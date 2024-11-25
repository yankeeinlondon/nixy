# Nixy

> use the [Nix Package Manager](https://search.nixos.org/) like a pro on MacOS

## What is this Nixy thing?

Well first let's talk very briefly about **Nix** and what it is as that can be a source of confusion. **Nix** is effectively three things:

1. A Linux Distribution (aka, NixOS)
2. A Package Manager (aka, NixPkgs)
3. A functional language (aka, NixDSL)

Now it's true that _you could_ fully configure macOS using the **NixDSL** and you would be a heroic person should you choose to slid down that slope. But for many who use macOS, we like baby steps and we prefer that we can live in the messy and mutable world of macOS and Homebrew while _taking strides_ toward being a cleaner more immutable citizen with **NixPkgs**. If you're this person than **Nixy** might be of use to you.

Maybe it was the massively large package space that attracted you to NixPkgs but maybe you also heard about how Nix might provide a way to just install a fresh version of macOS and get your "working environment" with all common programs, configuration, etc. installed in one simple step. That _might_ be what you have but our mutable/messy ways have a way of interfering with that dream.

Let's take a "for instance":

- let say you wanted to grab the popular `fzf` fuzzy finder from NixPkgs
- you go to the search page and find it listed
- then you refer to the instructions it provides which is something like running `nix-env -iA nixpkgs.fzf`
- Now when you run `which fzf` you'll see that fzf is indeed originating from the `${HOME}/.nix-profile/bin/fzf`
- Inevitably you will secretly laugh to yourself and think or say something along the lines of "oh boy, a year ago I'd have just installed this using homebrew and now I've done it 'the right way'"
- sadly in a year from now, or at least after you've started using nixy you'll realize you have not yet done it the "right way"

Sure at any point you can run `ll` and see a _list_ of symbolic links to all the packages you've installed and maybe before you're next fresh install you'll use this ability to create a package installer for your new device but already feels clumsy.

Instead, with **Nixy**, let's walk through the same scenario:

- you run `nixy install fzf`
  - to me that's already nicer as it's shorter and easier to remember
- here's the best part, not only is `fzf` now immediately available to you but ...
  - a `nix.conf` file has been created/updated which has your inventory of packages
  - you'll want this `nix.conf` file to reside somewhere that get's shared across your devices and/or somewhere that is backed up
- the next time you want to install "all of your programs" onto a fresh macOS install then you all you need to do (after installing Nix Package Manager) is:
  - copy and paste this to your terminal: XXX and press enter
  - this installs `nixy` to your `/usr/local/bin` folder and runs `nixy install` which will interactively  prompt you if you want to install some or all of you packages.


---
date: '2025-07-11T16:35:50+03:00'
draft: true
title: 'Introducing My Personal Nix Repository'
description: "A short post on my Nix User Repository (NUR), what's inside, and how to use it."
tags: ["nix", "nixos", "nur"]
---

This is the first post on my blog, where I plan to document technical projects and my learning journey. I thought a good starting point would be a project I've been maintaining for my own use: a personal Nix repository.

As a NixOS user, I occasionally need a package that isn't in the main `nixpkgs` repository, or I require a specific version for a project. This led me to package them myself and, subsequently, to create a system for managing them. The result is my own Nix User Repository (NUR).

### What is NUR?

For those who may not be familiar, NUR (the Nix User Repository) is a community-driven ecosystem that allows individuals to create and share their own repositories of Nix packages. It provides a standardized way to make these packages discoverable and usable by others, supplementing the official `nixpkgs` collection. You can learn more about it at the [nix-community/NUR](https://github.com/nix-community/NUR) repository.

### How to Use NUR

This post assumes you are using [Flakes](https://wiki.nixos.org/wiki/Flakes). If you aren't familiar with them, I recommend reading the [wiki page](https://wiki.nixos.org/wiki/Flakes) and this [book for beginners](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes).

You can use my repository in two ways: by including the entire NUR community repository, or by adding only my personal repository. Each method has its pros and cons. Using the whole NUR repository gives you access to a vast number of packages, but at the cost of a larger flake input and slower updates. On the other hand, using a personal repository is lighter, and some developers (myself included) provide a binary cache. This cache allows you to skip building packages from source, saving you time.

#### Using community NUR repository

If you want to use whole NUR repo, add the following to your `flake.nix`:

```nix
{
  inputs = {
    # Your other inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # NUR repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # Adds the NUR overlay
        nur.modules.nixos.default
        # NUR modules to import
        nur.legacyPackages."${system}".repos.ataraxiasjel.modules.syncyomi
        # This adds the NUR nixpkgs overlay.
        # Usage example:
        # ({ pkgs, ... }: {
        #   environment.systemPackages = [ pkgs.nur.repos.ataraxiasjel.hello-nur ];
        # })
      ];
    };
  };
}
```

#### Using personal NUR repository

If you want to use someone's personal repository (mine, for example), add the following to your `flake.nix`:

```nix
{
  inputs = {
    # Your other inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Personal nur repo
    ataraxiasjel-nur = {
      url = "github:ataraxiasjel/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ataraxiasjel-nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # Add overlay
        ataraxiasjel-nur.overlays.default
        # Or some module
        ataraxiasjel-nur.nixosModules.rustic
        # And some packages
        ({ pkgs, ... }: {
          # If you use default overlay:
          # environment.systemPackages = [ pkgs.waydroid-script ];
          # Or if you don't:
          environment.systemPackages = [ ataraxiasjel.packages.${system}.waydroid-script ];
        })
      ];
    };
  };
}
```

Notice the `inputs.nixpkgs.follows` line. This setting is important when deciding whether to use a binary cache, if the repository owner provides one.

If you don't want to use a binary cache, the example above works as-is. To use a binary cache, however, you'll need to remove the `inputs.nixpkgs.follows = "nixpkgs";` line. Then, add the binary cache to your system configuration and rebuild. It's crucial to do this *before* adding any packages from the repository; otherwise, Nix won't use the cache and will build the packages locally.

For example, to use my binary cache, add this to your system configuration:

```nix
{ ... }:
{
  nix.settings = {
    substituters = [
      "https://ataraxiadev-foss.cachix.org"
    ];
    trusted-public-keys = [
      "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
    ];
  };
}
```

For other caches this address and key would be different.

### What's Inside My Repository?

This repository is a work in progress and primarily serves my own needs. Currently, it includes these notable packages:

* `waydroid-script`: A Python script to add OpenGapps, Magisk, and the libhoudini and libndk translation libraries to Waydroid.
* `syncyomi`: An open-source project for synchronizing the Tachiyomi manga reader across multiple devices.
* `ocis-bin`: ownCloud Infinite Scale (oCIS), a file syncing and sharing platform. Multiple versions are available.
* and more...

For a full list of packages, you can consult the [NUR package search](https://nur.nix-community.org/repos/ataraxiasjel/).

My repository also contains several NixOS modules, including:

* `authentik`: A module for managing the Authentik service, with support for the main service and the LDAP outpost.
* `syncyomi`: A module to manage the SyncYomi systemd service.
* `rustic`: An alternative backup solution to restic. An example usage can be found in my [NixOS configuration](https://github.com/AtaraxiaSjel/nixos-config/blob/d22c2abb30f56f5a8bfaaafd66f5e1e983a00c91/hosts/orion/backups.nix).

You can see the full list of modules [here](https://github.com/AtaraxiaSjel/nur/tree/master/modules). I also regularly update the repository's README with a list of modules and their descriptions.

I have several overlays in my repository, including:

* `default`: The default overlay that includes all packages from the repository, some of which may override packages from `nixpkgs`. Use this with caution, as I might change package names or override upstream packages without notice.
* `grub2-unstable-argon2`: Overrides `grub2` packages to include a patch set for Argon2 key support. I have been using this for over a year without any issues. Currently, these `grub2` packages are not pushed to the binary cache.

### Conclusion

The source code for my NUR is available on GitHub: **https://github.com/AtaraxiaSjel/nur**.

I hope this might be useful to someone else. Feedback or issues are welcome and can be submitted on the GitHub repository.

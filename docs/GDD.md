# Eldoria: Shadow Realms — GDD

## Overview
A 3D fantasy dungeon crawler in Godot 4.4.1. Third-person action-adventure. Player explores dungeon levels, fights skeleton warriors and goblin archers, collects keys, finds the exit portal.

## Genre
3D Action-Adventure / Dungeon Crawler

## Core Mechanics
- **Movement**: WASD + mouse look (FPS-style)
- **Combat**: Left-click melee attack with sword, right-click block
- **Health System**: 100 HP, potions restore 25 HP
- **Inventory**: Collect keys, potions, coins
- **Levels**: Procedurally generated dungeon rooms connected by corridors
- **Enemies**: Skeletons (melee), Goblins (ranged with arrows), Skeleton Archers (ranged)
- **Objective**: Find the Golden Key, defeat the Boss Skeleton, escape through the Portal

## Art Style
- FAL-generated textures for walls, floors, ceilings
- FAL-generated billboard sprites for enemies (always face camera)
- FAL-generated skybox/HDRI
- Low-poly geometric environment (CSG boxes with textures)
- Dark fantasy atmosphere with torch light

## Technical
- Godot 4.4.1, Forward+ renderer
- CharacterBody3D player with spring-arm camera
- Area3D hit detection for combat
- NavigationAgent3D for enemy pathfinding
- Procedural room generation via CSG shapes

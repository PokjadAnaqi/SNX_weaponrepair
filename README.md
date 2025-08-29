
## 📦 Features
- Weapon repair system for **ox_inventory** weapon durability  
- Built with **ox_lib** (markers, points, notify, progress bar, context menu)  
- Configurable per-location:  
  - Use **ox_target** or **E + marker**  
  - Spawn **bench props** automatically  
  - Custom blips (global or override per location)  
- **For SNX_VIPMenu Integration 🎖️**  
  - Repair menu accessible via VIP Menu  
  - Optional VIP discount system  
  - Standing welding animation for VIP repair  

---

## ⚙️ Dependencies
- [ox_lib](https://github.com/CommunityOx/ox_lib)  
- [ox_inventory](https://github.com/CommunityOx/ox_inventory)
- [ox_target](https://github.com/CommunityOx/ox_target) *(optional)*  
- [qbx_core](https://github.com/Qbox-project/qbx_core) **or** [qb-core](https://github.com/qbcore-framework/qb-core)

- **SixtyNine Survival Base** → [Join Discord](https://discord.gg/gCBrnn9bxN)  

---

## 📂 Installation
1. Download / clone repo into your `resources/[snx]/SNX_weaponrepairv2` folder.  
2. Ensure dependencies are installed and running.  
3. Add to your `server.cfg` in correct order:
   ```cfg
   ensure ox_lib
   ensure ox_inventory
   ensure qbx_core   # or qb-core
   ensure ox_target # optional
   ensure SNX_weaponrepair

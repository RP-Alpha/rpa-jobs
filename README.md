# rpa-jobs

<div align="center">

![GitHub Release](https://img.shields.io/github/v/release/RP-Alpha/rpa-jobs?style=for-the-badge&logo=github&color=blue)
![GitHub commits](https://img.shields.io/github/commits-since/RP-Alpha/rpa-jobs/latest?style=for-the-badge&logo=git&color=green)
![License](https://img.shields.io/github/license/RP-Alpha/rpa-jobs?style=for-the-badge&color=orange)
![Downloads](https://img.shields.io/github/downloads/RP-Alpha/rpa-jobs/total?style=for-the-badge&logo=github&color=purple)

**Civilian Job Framework with XP System**

</div>

---

## ✨ Features

- 🚚 **Delivery Job** - Truck delivery loop with GPS
- 📈 **XP System** - Earn experience for job completion
- ⬆️ **Leveling** - Unlock better pay multipliers
- ⚙️ **Configurable** - Easy to add new routes

---

## 📥 Installation

1. Download the [latest release](https://github.com/RP-Alpha/rpa-jobs/releases/latest)
2. Extract to your `resources` folder
3. Add to `server.cfg`:
   ```cfg
   ensure rpa-jobs
   ```

---

## ⚙️ Configuration

Configure jobs in `config.lua`:

```lua
Config.Delivery = {
    Depot = vector3(x, y, z),
    Vehicle = 'boxville',
    Pay = 250
}

Config.Levels = {
    [1] = { xp = 0, multiplier = 1.0 },
    [2] = { xp = 100, multiplier = 1.1 },
    [3] = { xp = 250, multiplier = 1.25 }
}
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/RP-Alpha">RP-Alpha</a></sub>
</div>

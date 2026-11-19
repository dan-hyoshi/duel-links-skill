# Custom EdoPro Duel Links Skill

Welcome to the official repository for the **Custom Yu-Gi-Oh! Card**. Designed for use in the **EDOPro** simulator.

---

## 🛠️ Prerequisites

- [Edopro](https://discord.gg/ygopro-percy)

## 🛠️ How to Add to EDOPro

To use these cards in your EDOPro client, follow these steps to link this repository:

1. **Locate your EDOPro folder**: Open the main directory where your EDOPro executable is located.
2. **Open the Config folder**: Navigate to `config`.
3. **Edit user_configs.json**: Open the `user_configs.json` file with a text editor (like Notepad++ or VS Code).
4. **Update the Repos Array**: Find the `"repos": []` section and paste the following block inside the square brackets:

```json
{
  "url": "https://github.com/<DAN_HYOSHI EMAIL ACCOUNT>/YGO-DuelLinks",
  "repo_name": "Duel-Links",
  "repo_path": "./repositories/DuelLinks",
  "has_core": false,
  "data_path": "databases",
  "script_path": "scripts",
  "pics_path": "pics",
  "should_update": true,
  "should_read": true
}
```

# Duel Links Skill Database

> [!NOTE]
> Any Skill that **plays** a monster to the field is treated as a Special Summon and will trigger appropriate effects. Ensure you do not activate effects during that Special Summon unless intended.

---

### 📂 Available Skills

#### <h3>

  <img src="./images/download (1).webp" width="24" style="vertical-align: middle; margin-right: 2px;" />
   <strong>Archive Skills</strong>
</h3>

|                 Script ID                 | Skill Name                     | Archetype / Focus |                                       Status                                        |   Date   |
| :---------------------------------------: | :----------------------------- | :---------------- | :---------------------------------------------------------------------------------: | :------: |
| [**619080301**](./scripts/c619080301.lua) | **Precious Card of the Dark**  | DARK              |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080302**](./scripts/c619080302.lua) | **Precious Card of the Light** | LIGHT             |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080303**](./scripts/c619080303.lua) | **Precious Card of the Water** | WATER             |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080304**](./scripts/c619080304.lua) | **Precious Card of the Wind**  | WIND              |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080307**](./scripts/c619080307.lua) | **Beasts From the Abyss**      | Branded-Bystial   |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080309**](./scripts/c619080309.lua) | **The Courage to Rise**        | Centur-Ion        |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080310**](./scripts/c619080310.lua) | **Eyes of Sovereign Defiance** | Snake-Eyes        |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080313**](./scripts/c619080313.lua) | **Goblin Bikers on a Rampage** | Goblin Biker      |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        | Oct 2026 |
| [**619080314**](./scripts/c619080314.lua) | **A World of Ice and Water**   | Icejade           | ![Partial](<https://img.shields.io/badge/Status-Partial_(No_Dmg_Reduction)-orange>) | Oct 2026 |
| [**619080315**](./scripts/c619080315.lua) | **Rescue-ACE**   | Rescue-ACE           | ![Partial](<https://img.shields.io/badge/Status-Partial_(No_3rd_Effect)-orange>) | Nov 2026 |

#### <h3 style="vertical-align: middle; margin-right: 8px;">

  <img src="./images/download.webp" width="20" style="vertical-align: middle; margin-right: 2px;" /> <strong>Characters Skills</strong>
</h3>

|   Script ID   | Skill Name                         | Archetype / Character                 |                                       Status                                        |   Date   |
| :-----------: | :--------------------------------- | :------------------------------------ | :---------------------------------------------------------------------------------: | :------: |
| [**619080305**](./scripts/c619080305.lua) | **The Eye of the United Dragon**   | Dark Magician / Yami Yugi             |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080306**](./scripts/c619080306.lua) | **I'll Show You Perfection!**      | Cyber Dragon / Zane Truesdale         |  ![Partial](<https://img.shields.io/badge/Status-Partial_(No_3rd_Effect)-orange>)   |
| [**619080308**](./scripts/c619080308.lua) | **A Shining Miracle Arrives**      | Stardust-Majestic Dragon / Fudo Yusei |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        | Oct 2026 |
| [**619080311**](./scripts/c619080311.lua) | **Bonds of the Converging Stars**  | Stardust-Quasar / Fudo Yusei          |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        |
| [**619080312**](./scripts/c619080312.lua) | **Thorns of Hatred in Full Bloom** | Rose Dragon / Akiza Izinski           | ![Partial](<https://img.shields.io/badge/Status-Partial_(No_Dmg_Reduction)-orange>) | Oct 2026 |


### Changelogs
|                 Script ID                 | Skill Name                     | Changes |                                       Status                                        |   Date   |
| :---------------------------------------: | :----------------------------- | :---------------- | :---------------------------------------------------------------------------------: | :------: |
| [**619080301**](./scripts/c619080301.lua) | **Precious Card of the Dark**  | DARK Attribute Requirement: 6 -> 10              |        ![Ready](https://img.shields.io/badge/Status-Implemented-brightgreen)        | This is Placeholder example
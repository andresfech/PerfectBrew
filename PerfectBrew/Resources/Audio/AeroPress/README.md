# Audio Files for AeroPress Recipes

This folder contains audio recordings for each step of the AeroPress brewing recipes.

## Folder Structure

```
Audio/
└── AeroPress/
    ├── 2024_World_Champion/          # George Stanica (Romania)
    ├── 2023_World_Champion/          # Tay Wipvasutt (Thailand)
    ├── 2022_World_Champion/          # Jibbi Little (Australia)
    ├── 2021_World_Champion/          # Tuomas Merikanto (Finland)
    ├── Standard_1_Person/            # Standard method for 1 person
    ├── Standard_2_Person/            # Standard method for 2 people
    ├── Inverted_1_Person/            # Inverted method for 1 person
    ├── Inverted_2_Person/            # Inverted method for 2 people
    └── Championship_Concentrate/     # Championship concentrate recipe
```

## File Naming Convention

For each recipe, create audio files with the following naming pattern:

```
step_1.m4a    # First brewing step
step_2.m4a    # Second brewing step
step_3.m4a    # Third brewing step
...
step_N.m4a    # Nth brewing step
```

## Audio File Specifications

- **Format**: .m4a (AAC codec)
- **Quality**: 128-192 kbps recommended
- **Language**: Spanish (español)
- **Duration**: Keep each step audio concise (10-30 seconds)

## Example for 2024 World Champion Recipe

```
2024_World_Champion/
├── step_1.m4a    # "Add 18.0 g of grounds to the inverted AeroPress..."
├── step_2.m4a    # "Pour the first 50 g of 96 °C water..."
├── step_3.m4a    # "Pour the second 50 g of 96 °C water..."
├── step_4.m4a    # "Stir gently in a North–South–East–West pattern..."
├── step_5.m4a    # "Give a gentle swirl to the AeroPress..."
├── step_6.m4a    # "When press is complete, add warm water..."
└── step_7.m4a    # "Add an additional 20–30 g of room-temperature water..."
```

## How to Add New Audio Files

1. **Record** the audio for each step
2. **Convert** to .m4a format if needed
3. **Name** files according to the convention
4. **Place** in the appropriate recipe folder
5. **Update** the recipe JSON to include audio file references

## Notes

- Keep audio files small in size for app performance
- Ensure clear pronunciation and consistent volume
- Consider adding multiple language versions if needed
- Test audio playback in the app after adding files

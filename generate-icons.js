const sharp = require("sharp");
const fs = require("fs");
const path = require("path");

// Read the Contents.json file
const contents = require("./KeysVsClicks/Assets.xcassets/AppIcon.appiconset/Contents.json");

// Create a Set to store unique sizes (to avoid processing duplicates)
const processedSizes = new Set();

async function generateIcons() {
  try {
    const sourceImage =
      "./KeysVsClicks/Assets.xcassets/AppIcon.appiconset/1024.png";

    // Create a promise array for all resize operations
    const resizePromises = contents.images.map(async (image) => {
      const expectedSize = parseInt(image["expected-size"]);

      // Skip if we've already processed this size
      if (processedSizes.has(expectedSize)) {
        return;
      }

      processedSizes.add(expectedSize);

      const outputPath = path.join(
        "./KeysVsClicks/Assets.xcassets/AppIcon.appiconset",
        `${expectedSize}.png`
      );

      console.log(`Generating ${expectedSize}x${expectedSize} icon...`);

      return sharp(sourceImage)
        .resize(expectedSize, expectedSize, {
          fit: "contain",
          background: { r: 0, g: 0, b: 0, alpha: 0 },
        })
        .png()
        .toFile(outputPath);
    });

    // Wait for all resize operations to complete
    await Promise.all(resizePromises);
    console.log("All icons generated successfully!");
  } catch (error) {
    console.error("Error generating icons:", error);
  }
}

generateIcons();

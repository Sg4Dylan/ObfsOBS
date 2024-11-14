# ObfsOBS
ObfsOBS is a pair of filters designed to obfuscate and de-obfuscate images output by OBS Studio.

## Obfuscate
1. Download the script and save it into dir `obfsobs` on your computer.  
2. Open OBS Studio.  
3. Go to Tools, then select Scripts.  
4. Next, click "Add" to add filters. Add the following filters for the Obfuscate process: `Grid Shuffle X-Axis`, `Grid Shuffle Y-Axis`.

## De-obfuscate
1. Download the script and save it into dir `obfsobs` on your computer.  
2. Open OBS Studio.  
3. Go to Tools, then select Scripts.  
4. Next, click "Add" to add filters. Add the following filters for the De-obfuscate process: `Grid Reorder X-Axis`, `Grid Reorder Y-Axis`.

## Tips
To optimize obfuscation, apply filters sequentially in an X-Y-X pattern, adjusting tile sizes and random seeds for each iteration.
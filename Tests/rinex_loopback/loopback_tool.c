
#include "rinex.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input_rinex_nav> <output_rinex_nav>\n", argv[0]);
        return 1;
    }

    const char *infile = argv[1];
    const char *outfile = argv[2];
    nav_t nav = {0};
    rnxopt_t opt = {0};
    int i, stat;
    FILE *fp;

    // 1. Parse input file
    printf("Parsing: %s\n", infile);
    stat = readrnx(infile, 0, "", NULL, &nav, NULL);
    if (stat <= 0) {
        fprintf(stderr, "Failed to parse RINEX file: %s\n", infile);
        return 1;
    }
    printf("Parsed %d ephemeris.\n", nav.n);
// 2. Set options for generation
// Detect version from input file (simplified)
if (!(fp = fopen(infile, "r"))) {
    perror("fopen input for version check");
    return 1;
}
char line[128];
if (fgets(line, sizeof(line), fp)) {
    opt.rnxver = atof(line);
    if (opt.rnxver == 0) opt.rnxver = 2.11; // fallback
}
fclose(fp);

opt.navsys = SYS_GPS|SYS_GLO|SYS_GAL|SYS_QZS|SYS_CMP|SYS_SBS; 
opt.outiono = 1;
opt.outtime = 1;
opt.outleaps = 1;
strcpy(opt.prog, "LOOPBACK_TEST");
printf("Setting output RINEX version: %.2f\n", opt.rnxver);

// 3. Open output file
if (!(fp = fopen(outfile, "w"))) {
    perror("fopen output");
    return 1;
}

    // 4. Output Header
    outrnxnavh(fp, &opt, &nav);

    // 5. Output Body
    for (i = 0; i < nav.n; i++) {
        outrnxnavb(fp, &opt, &nav.eph[i]);
    }

    fclose(fp);
    printf("Regenerated: %s\n", outfile);

    // Free memory
    free(nav.eph);
    free(nav.geph);
    free(nav.seph);

    return 0;
}

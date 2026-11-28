# Work Distribution – Noa Amar & Roni Natanson

## Homework 1 – Project setup and source proposals
- **Noa** created the public GitHub repository, connected it to the project folder, and wrote
  `README.md`.
- **Noa and Roni** chose the project topic together. **We** wrote the two source proposals in
  `SOURCE.md` together, and **Noa** uploaded them from her GitHub account.

## Homework 3 – Manual samples and schema
- **Noa** collected the 4 manual samples (16–19 November 2026, at different hours: morning, noon
  and evening) with `curl` and `jq`, and uploaded `raw/` from her GitHub account.
- **Roni** analysed the fields of the samples (which fields are constant and which change,
  units, missing fields), wrote the data schema in `SOURCE.md` based on this analysis, and
  uploaded it from her GitHub account.
- **Noa** reviewed `SOURCE.md` before it was uploaded.
- Each of us went over the other's part: Noa learned the schema and the reasons for each column,
  and Roni learned how the samples are collected.

## Homework 4 – Automatic collection script
- **Noa** wrote `bin/collect.sh`, ran it to check that it saves a correct sample
  (`raw/YYYY-mm-dd/HHMM.json.gz`), and uploaded it from her GitHub account.
- **Roni** downloaded the script, ran it on her own machine to check that it works there too,
  and wrote this file (`PAIR.md`) and uploaded it from her GitHub account.

## AI assistance
We used Claude to help prepare the collection commands and `collect.sh`, to analyse the fields of
our samples, and to structure and check `SOURCE.md`. We ran all commands ourselves and checked the
outputs. Each commit message also notes when we used Claude.

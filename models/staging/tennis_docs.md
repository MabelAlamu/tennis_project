{% docs player_hand %}
Player's dominant playing hand, with surrounding whitespace removed and blank values normalised to null.

One of the following values: 
| player_hand | Description                                     |
|------------ |-------------------------------------------------|
| **R**       | Player is right handed                          |
| **L**       | Player is left handed                           |
| **A**       | Player is ambidextrous, uses both hands to play |
| **U**       | Unknown                                         |

{% enddocs %}

{% docs player_backhand %}
Player's backhand style, with surrounding whitespace removed and blank values normalised to null.

One of the following values: 
| player_backhand | Description                      |
|------------     |----------------------------------|
| **1H**          | One-handed                       |
| **2H**          | Two-handed                       |
| **U**           | Unknown                          |

{% enddocs %}

{% docs player_entry%}
Entry category for the losing player, such as wildcard or qualifier, when supplied.

One of the following values: 
| Abbreviation | Meaning           | Description                                                                                                                       |
| ------------ | ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **WC**       | Wild Card         | Given a spot without qualifying, often for local players, past champions, or comeback players                                     |
| **Q**        | Qualifier         | Won through the qualifying rounds                                                                                                 |
| **LL**       | Lucky Loser       | Lost in qualifying but got into the main draw due to a withdrawal                                                                 |
| **PR**       | Protected Ranking | Used an injury-protected ranking to enter, bypassing the normal cutoff                                                            |
| **ALT**      | Alternate         | Next player in line who got in due to a late withdrawal; usually pre-tournament and not necessarily from qualifying               |
| **SE**       | Special Exempt    | Given a main draw spot because they were still competing in another tournament the previous week and couldn't play qualifying     |
| **ITF**      | ITF Entry         | Typically a lower-level ITF-ranked player, or someone entering through an ITF-administered pathway rather than the ATP entry list |
| **UG**       |                   |  |
| **NG**       |                   |  |

{% enddocs %}

{% docs atp_tourney_level%}
Classification for the tournament level.

One of the following values:
| Abbreviation | Tournament Level Name | Description / Details |
|  ---         | ---                   |  ---                  |
| **G**        | **Grand Slam**        | The four Majors: Australian Open, Roland Garros (French Open), Wimbledon, and US Open. |
| **M**        | **Masters 1000**      | ATP Masters 1000 series (top non-Grand Slam tour events awarding 1,000 points to the winner, e.g., Indian Wells, Miami, Rome). |
| **F**        | **Tour Finals**       | Season-ending championships featuring the top-ranked players (e.g., ATP Finals, Next Gen Finals, or historical equivalents like the Masters Grand Prix). |
| **500**      | **ATP 500**           | Mid-tier ATP Tour events awarding 500 ranking points to the champion (e.g., Barcelona, Halle, Beijing). |
| **250**      | **ATP 250**           | Standard ATP Tour events awarding 250 ranking points to the champion. |
| **A**        | **ATP Tour / Main Tour** | Standard main-tour ATP tournaments. Used for general tour-level events or historically for ATP events prior to modern tier classifications. |
| **P**        | **Pro Tour (Pre-Open Era)** | Standalone Professional Circuit events prior to April 1968 (e.g., US Pro, Wembley Pro, French Pro) when professional players were barred from Grand Slams. |
| **D**        | **Davis Cup**         | Men's international team competition representing national teams. |
| **O**        | **Olympic Games**     | The Olympic Tennis Event held every four years. |
{% enddocs %}

{%docs wta_tourney_level%}
Classification for the tournament level.

One of the following values:
| Abbreviation | Tournament Level Name | Description / Details |
| ---          |  ---                  | ---                   |
| **G** | **Grand Slam** | The four Majors: Australian Open, Roland Garros (French Open), Wimbledon, and US Open. |
| **1000** | **WTA 1000** | Top-tier non-Grand Slam tour events awarding up to 1,000 points (e.g., Indian Wells, Miami, Madrid, Rome, Beijing). Introduced in the 2021 tier structure reset. |
| **500** | **WTA 500** | Mid-tier WTA events awarding 500 ranking points (e.g., Charleston, Stuttgart, Eastbourne). Replaced the former WTA Premier category in 2021. |
| **250** | **WTA 250** | Regular WTA tour events awarding 250 ranking points (e.g., Auckland, Rabat, Linz). Replaced WTA International in 2021. |
| **PM** | **Premier Mandatory** | Top non-Grand Slam category under the 2009–2020 WTA structure (Indian Wells, Miami, Madrid, Beijing). |
| **P5** | **Premier 5** | High-tier events under the 2009–2020 structure offering 900 points (Doha/Dubai, Rome, Cincinnati, Canada, Wuhan). |
| **P** | **Premier** | Regular Premier-level tournaments under the 2009–2020 tiering system (equivalent to today's WTA 500). |
| **I** | **International** | Standard WTA tour events under the 2009–2020 system (equivalent to today's WTA 250). |
| **T1 / T2 / T3 / T4 / T5** | **Tier I – Tier V** | Legacy WTA classification system used from 1988 through 2008, where Tier I represented the highest non-Slam events and Tier V represented the entry level. |
| **F / YEC** | **WTA Finals / Year-End Championships** | Season-ending championships featuring the top-ranked women singles players and doubles teams. |
| **W** | **WTA 125 / WTA Challenger** | Secondary tour events (WTA 125 series) that bridge ITF circuit events and main WTA tour events. |
| **A** | **Other Tour / Main Tour** | General WTA main-tour designation or legacy entry for regular tour events across dataset variations. |
| **D** | **Billie Jean King Cup** | Women's international team competition representing national teams (formerly Fed Cup / Federation Cup). |
| **O** | **Olympic Games** | The Olympic Tennis Event held every four years. |
{% enddocs %}
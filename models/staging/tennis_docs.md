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
Entry category through which the player joined the tournament draw.

One of the following values: 
| Abbreviation | Official Name | Description & Context |
| :--- | :--- | :--- |
| **WC** | Wild Card | A spot given at the tournament discretion to popular local players, rising stars, or top players returning from absence. |
| **Q** | Qualifier | A player who won their way into the main draw by winning preliminary qualification matches. |
| **LL** | Lucky Loser | A player who lost in the final round of qualifying but got into the main draw anyway to replace a last-minute withdrawal. |
| **PR** | Protected Ranking | A player using a frozen ranking slot allowed by the tour due to a long-term injury or maternity leave. |
| **SR** | Special Ranking | The exact same mechanism as PR. The WTA tour uses "Special Ranking", while the ATP tour uses "Protected Ranking". |
| **ALT** | Alternate | A player next in line to get into the tournament if an accepted player withdraws before the event starts. |
| **A** | Alternate | A shorthand abbreviation for Alternate, frequently used in older database schemas or live chair-umpire data feeds. |
| **SE** | Special Exempt | A player who couldn't play the qualifying matches because they were busy winning or playing in the finals of a tournament the previous week. |
| **ITF** | ITF Place | An Olympic-specific entry given to continental games champions (e.g., Asian Games gold medallists) or former Olympic champions. |
| **IP** | ITF Place | The older/historical acronym for "ITF Place" used in Olympic draws prior to Tokyo 2020. |
| **UP** | Universality Place | An Olympic-specific invitation granted to under-represented nations to ensure global representation. |
| **NG** | Next Gen | NG represents modern ATP Accelerator Programmes meant for direct developmental entry

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
FROM atdr.meo.ws/archiveteam/urls-grab
RUN DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io update \
  && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io install tor \
  && rm -rf /var/lib/apt/lists/*
COPY . /grab
RUN grep "VERSION = '20240401.01'" pipeline.py
RUN sed -i "s|TRACKER_ID = 'urls'|TRACKER_ID = 'urls-tor'|" pipeline.py \
  && sed -i -E "s|VERSION = '[0-9]+\.[0-9]+'|VERSION = '20240404.01'|" pipeline.py \
  && sed -i -E "s|WGET_AT_COMMAND = \[([^]]+)\]|WGET_AT_COMMAND = \['torify', \1\]|" pipeline.py \
  && sed -i "s|title = 'URLs'|title = 'URLs on Tor'|" pipeline.py \
  && sed -i -E 's|<a href="[^"]+">Leaderboard</a>|<a href="https://tracker\.archiveteam\.org/urls-tor/">Leaderboard</a>|' pipeline.py \
  && sed -i -E "s|USE_DNS_SECURITY = [A-Za-z0-9]+|USE_DNS_SECURITY = False|" pipeline.py \
  && sed -i "s|CheckIP(),|StartTor(),CheckIP(),CheckForBadConfig(),|" pipeline.py \
  && sed -n -i -e "/class CheckRequirements/r pipeline_additional.py" -e 1x -e '2,${x;p}' -e '${x;p}' pipeline.py \
  && sed -i -E "s|'timeout': [0-9]+,|'timeout': 120,|" pipeline.py \
  && sed -i -E "s|'--timeout', '[0-9]+',|'--timeout', '120',|" pipeline.py \
  && sed -i -E "s|'--host-lookups',.+||" pipeline.py \
  && sed -i -E "s|'--hosts-file',.+||" pipeline.py \
  && sed -i -E "s|'--resolvconf-file',.+||" pipeline.py \
  && sed -i -E "s|'--dns-servers',.+||" pipeline.py \
  && sed -i "s|'--reject-reserved-subnets',||" pipeline.py \
  && sed -i "s|item\['dict_project'\] = TRACKER_ID|item\['dict_project'\] = 'urls'|" pipeline.py \

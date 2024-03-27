FROM atdr.meo.ws/archiveteam/urls-grab
RUN DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io update \
  && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io install tor
COPY . /grab
RUN grep "VERSION = '20240327.06'" pipeline.py
RUN sed -i "s|TRACKER_ID = 'urls'|TRACKER_ID = 'urls-onion'|" pipeline.py \
  && sed -i -E "s|VERSION = '[0-9]+\.[0-9]+'|VERSION = '20240327.01'|" pipeline.py \
  && sed -i -E "s|WGET_AT_COMMAND = \[([^]]+)\]|WGET_AT_COMMAND = \['torify', \1\]|" pipeline.py \
  && sed -i "s|title = 'URLs'|title = 'URLs on Tor'|" pipeline.py \
  && sed -i -E 's|<a href="[^"]+">Leaderboard</a>|<a href="https://tracker\.archiveteam\.org/urls-onion/">Leaderboard</a>|' pipeline.py \
  && sed -i -E "s|USE_DNS_SECURITY = [A-Za-z0-9]+|USE_DNS_SECURITY = False|" pipeline.py \
  && sed -i "s|CheckIP(),|StartTor(),CheckIP(),|" pipeline.py \
  && sed -n -i -e "/class CheckRequirements/r pipeline_additional.py" -e 1x -e '2,${x;p}' -e '${x;p}' pipeline.py \
  && sed -i -E "s|'--timeout', '[0-9]+',|'--timeout', '120',|" pipeline.py \
  && sed -i -E "s|'--host-lookups',.+||" pipeline.py \
  && sed -i -E "s|'--hosts-file',.+||" pipeline.py \
  && sed -i -E "s|'--resolvconf-file',.+||" pipeline.py \
  && sed -i -E "s|'--dns-servers',.+||" pipeline.py \
  && sed -i "s|'--reject-reserved-subnets',||" pipeline.py \
  && sed -i -E "s|TRACKER_HOST, TRACKER_ID, MULTI_ITEM_SIZE|TRACKER_HOST, 'arkivertest5', MULTI_ITEM_SIZE|" pipeline.py \
  && sed -i "s|item\['dict_project'\] = TRACKER_ID|item\['dict_project'\] = 'urls'|" pipeline.py \
  && sed -i -E "s|MoveFiles(),|#MoveFiles(),|" pipeline.py

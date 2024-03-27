
class StartTor(SimpleTask):
    def __init__(self):
        SimpleTask.__init__(self, 'ConnectTor')
        
    def process(self, item):
        command = ['service', 'tor']
        kwargs = {
            'timeout': 60,
            'capture_output': True
        }
        returned = subprocess.run(command+['status'], **kwargs)
        if b'tor is running.' not in returned.stdout:
            returned = subprocess.run(command+['start'], **kwargs)
            assert b'done.' in returned.stdout
            returned = subprocess.run(command+['status'], **kwargs)
            assert b'tor is running.' in returned.stdout
            print('You are now connected to Tor.')


class CheckIP(SimpleTask):
    def __init__(self):
        SimpleTask.__init__(self, 'CheckIP')
        self._counter = 0
        
    def process(self, item):
        if self._counter <= 0:
            command = WGET_AT_COMMAND + [
                '--output-document', '-',
                '--max-redirect', '0',
                '--save-headers',
                '--no-check-certificate',
                '--no-hsts'
            ]
            kwargs = {
                'timeout': 60,
                'capture_output': True
            }

            url = 'https://check.torproject.org/'
            returned = subprocess.run(command+[url], **kwargs)
            assert returned.returncode == 0, 'Invalid return code {} on {}.'.format(returned.returncode, url)
            assert b'Congratulations. This browser is configured to use Tor.' in returned.stdout, 'Tor is not being used.'
            
            url = 'https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion/'
            returned = subprocess.run(command+[url], **kwargs)
            assert returned.returncode == 0, 'Invalid return code {} on {}.'.format(returned.returncode, url)
            assert b'<title>DuckDuckGo</title>' in returned.stdout,  'Cannot access DuckDuckGo onion site.'
            
            url = 'http://legacy-api.arpa.li/now'
            returned = subprocess.run(
                command+[url],
                **kwargs
            )
            assert returned.returncode == 0, 'Invalid return code {} on {}.'.format(returned.returncode, url)
            assert re.match(
                b'^HTTP/1\\.1 200 OK\r\n'
                b'Server: openresty\r\n'
                b'Date: [A-Z][a-z]{2}, [0-9]{2} [A-Z][a-z]{2} 202[0-9] [0-9]{2}:[0-9]{2}:[0-9]{2} GMT\r\n'
                b'Content-Type: text/plain\r\n'
                b'Connection: keep-alive\r\n'
                b'Content-Length: 1[0-9]\r\n'
                b'Cache-Control: no-store\r\n'
                b'\r\n'
                b'[0-9]{10}\\.[0-9]{1,3}$',
                returned.stdout
            ), 'Bad stdout on {}, got {}.'.format(url, repr(returned.stdout))

            actual_time = float(returned.stdout.rsplit(b'\n', 1)[1])
            local_time = time.time()
            max_diff = 180
            diff = abs(actual_time-local_time)
            assert diff < max_diff, 'Your time {} is more than {} seconds off of {}.'.format(local_time, max_diff, actual_time)

        # Check only occasionally
        if self._counter <= 0:
            self._counter = 30
        else:
            self._counter -= 1



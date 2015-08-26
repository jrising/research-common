## COPIED from agmodels

import urllib, multiprocessing, datetime, contextlib

def _urlread(url):
    with contextlib.closing(urllib.urlopen(url)) as page:
        return page.read()

def urlread(url):
    p = multiprocessing.Pool(1)
    deferred = p.apply_async(_urlread, [url])
    try:
        result = deferred.get(30)
    except multiprocessing.TimeoutError:
        print "Timed out on " + url
        result = None

    p.terminate()
    return result

class IRIDLSource:
    def __init__(self, url):
        self.url = url

    def get_ll_value(self, latitude, longitude):
        fullurl = self.url + "Y/%f/VALUE/X/%f/VALUE/[X]data.tsv" % (latitude, longitude)
        try:
            return float(urlread(fullurl))
        except Exception as e:
            print fullurl
            raise e

    def get_ll_range(self, swlat, swlon, nelat, nelon):
        fullurl = self.url + "Y/(%f)(%f)RANGEEDGES/X/(%f)(%f)RANGEEDGES/[X]data.tsv" % (swlat, nelat, swlon, nelon)
        try:
            data = urlread(fullurl)
            lines = data.split("\n")[:-1]
            return map(lambda line: map(float, line.split("\t")), lines)
        except Exception as e:
            print fullurl
            raise e

    def get_ll_times(self, latitude, longitude, date1, date2):
        if isinstance(date1, datetime.datetime):
            date1 = date1.strftime("%d %b %Y")
        if isinstance(date2, datetime.datetime):
            date2 = date2.strftime("%d %b %Y")

        fullurl = self.url + "X/%f/VALUE/Y/%f/VALUE/T/(%s)(%s)RANGEEDGES/[T]data.tsv" % (longitude, latitude, date1, date2)
        try:
            return map(float, urlread(fullurl).split("\t"))
        except Exception as e:
            print fullurl
            raise e

    def get_times(self, date1, date2):
        if isinstance(date1, datetime.datetime):
            date1 = date1.strftime("%d %b %Y")
        if isinstance(date2, datetime.datetime):
            date2 = date2.strftime("%d %b %Y")

        fullurl = self.url + "T/(%s)(%s)RANGEEDGES/[T]data.tsv" % (date1, date2)
        try:
            #return map(float, urlread(fullurl).split("\t"))
            with contextlib.closing(urllib.urlopen(fullurl)) as page:
                return map(float, page.read().split("\t"))
        except Exception as e:
            print fullurl
            raise e


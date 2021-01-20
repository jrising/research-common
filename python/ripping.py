import os, urllib2, csv
from bs4 import BeautifulSoup
from bs4.element import Tag

def get_soup(urlreq):
    if type(urlreq) is str:
        print urlreq

    # Open the URL
    reader = urllib2.urlopen(urlreq, timeout=30)
    # Parse the HTML
    return BeautifulSoup(reader, "lxml")

# Find all elements of a given kind of tag in the soup
def find_tags(soup, tagname, recurse_match=False):
    """Find all tags in the soup that have the given tag name (e.g., all <a> tags for links)."""

    matches = [] # all tags found

    check_tag = lambda name: name == tagname
    if isinstance(tagname, list):
        check_tag = lambda name: name in tagname

    # Iterate through all children that are instances of the Tag class
    for child in soup.children:
        if isinstance(child, Tag):
            # If this is our tag, add it; otherwise, recurse!
            if hasattr(child, 'name') and check_tag(child.name):
                matches.append(child)
                if recurse_match:
                    matches.extend(find_tags(child, tagname, recurse_match=recurse_match))
            else:
                matches.extend(find_tags(child, tagname, recurse_match=recurse_match))

    # Return the tags
    return matches

# Extract tags with a given class
def find_tags_class(soup, tagname, clsname):
    tags = find_tags(soup, tagname, recurse_match=True)

    return [tag for tag in tags if tag.has_attr('class') and tag['class'][0] == clsname]

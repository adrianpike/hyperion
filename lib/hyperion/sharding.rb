# Just my thoughts on strategy for this magick.


# crucial things:
# add nodes
# duplication level
# tools for shard analysis

# nice-to-haves
# add nodes transparently


## possible strategies
# hash on key (fastest, no extra storage overhead, but makes adding/removing difficult)
# sequential blocks of N keys get mapped to K nodes
# - things that we need to know centrally
# - - block storage required
# - - which block goes to which node(s)
# - - allocated storage space per node

# events that need to do magic:
# - new node comes up or goes down
# - duplication level changes


# global settings, that if changed will require intelligent migration:
# Block Size
# Duplication Level

# every node stores:
# block map
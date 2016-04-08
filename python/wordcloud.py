# Author: Andreas Christian Mueller <amueller@ais.uni-bonn.de>
# (c) 2012
#
# License: MIT
# Edited to our needs by: Konstantinos Konstantinidis <konkonst@iti.gr>

import random,os

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import numpy as np
from query_integral_image import query_integral_image

# FONT_PATH = "C:/Python33/Lib/site-packages/matplotlib/mpl-data/fonts/ttf/vera.ttf"
FONT_PATH = "C:/Python35/Lib/site-packages/pytagcloud-0.3.5-py3.3.egg/pytagcloud/fonts/DroidSans.ttf"


def make_wordcloud(words, counts, fname=None, font_path=None, width=400, height=200,
                   margin=5, ranks_only=False, backgroundweight=255):
    """Build word cloud using word counts, store in image.

    Parameters
    ----------
    words : numpy array of strings
        Words that will be drawn in the image.

    counts : numpy array of word counts
        Word counts or weighting of words. Determines the size of the word in
        the final image.
        Will be normalized to lie between zero and one.

    font_path : string
        Font path to the font that will be used.
        Defaults to DroidSansMono path.

    fname : sting
        Output filename. Extension determins image type
        (written with PIL).

    width : int (default=400)
        Width of the word cloud image.

    height : int (default=200)
        Height of the word cloud image.

    ranks_only : boolean (default=False)
        Only use the rank of the words, not the actual counts.

    backgroundweight : int (default=255)
        Weight that the background of the wordcloud is multiplied by.
        Applies in cases where there are more than 2 dimensions which charecterize the cloud;
        in our case it is the logged number of community population whose tweets resulted 
        in the cloud.

    Notes
    -----
    Larger Images with make the code significantly slower.
    If you need a large image, you can try running the algorithm at a lower
    resolution and then drawing the result at the desired resolution.

    In the current form it actually just uses the rank of the counts,
    i.e. the relative differences don't matter.
    Play with setting the font_size in the main loop vor differnt styles.

    Colors are used completely at random. Currently the colors are sampled
    from HSV space with a fixed S and V.
    Adjusting the percentages at the very end gives differnt color ranges.
    Obviously you can also set all at random - haven't tried that.

    """
    if len(counts) <= 0:
        print("We need at least 1 word to plot a word cloud, got %d."
              % len(counts))

    if font_path is None:
        font_path = FONT_PATH

    if not os.path.exists(font_path):
        raise ValueError("The provided font %s does not exist." % font_path)

    # normalize counts
    counts=[float(i/max(counts)) for i in counts]
    # sort words by counts
    inds = np.argsort(counts)[::-1]
    counts = [counts[i] for i in inds]
    words = [words[i] for i in inds]
    # create image
    img_grey = Image.new("L", (width, height))
    draw = ImageDraw.Draw(img_grey)
    integral = np.zeros((height, width), dtype=np.uint32)
    img_array = np.asarray(img_grey)
    font_sizes, positions, orientations = [], [], []
    # intitiallize font size "large enough"
    font_size = 1000
    # start drawing grey image
    for word, count in zip(words, counts):
        # alternative way to set the font size
        if not ranks_only:
            font_size = min(font_size, int(100 * np.log(count + 100)))
        while True:
            # try to find a position
            font = ImageFont.truetype(font_path, font_size, encoding = 'unic')
            # transpose font optionally
            orientation = random.choice([None, Image.ROTATE_90])
            transposed_font = ImageFont.TransposedFont(font, orientation=orientation)
            draw.setfont(transposed_font)
            # get size of resulting text
            box_size = draw.textsize(word)
            # find possible places using integral image:
            result = query_integral_image(integral, box_size[1] + margin,
                                          box_size[0] + margin)
            if result is not None or font_size == 0:
                break
            # if we didn't find a place, make font smaller
            font_size -= 1

        if font_size == 0:
            # we were unable to draw any more
            break

        x, y = np.array(result) + margin // 2
        # actually draw the text
        draw.text((y, x), word, fill="white")
        positions.append((x, y))
        orientations.append(orientation)
        font_sizes.append(font_size)
        # recompute integral image
        img_array = np.asarray(img_grey)
        # recompute bottom right
        # the order of the cumsum's is important for speed ?!
        partial_integral = np.cumsum(np.cumsum(img_array[x:, y:], axis=1),
                                     axis=0)
        # paste recomputed part into old image
        # if x or y is zero it is a bit annoying
        if x > 0:
            if y > 0:
                partial_integral += (integral[x - 1, y:]
                                     - integral[x - 1, y - 1])
            else:
                partial_integral += integral[x - 1, y:]
        if y > 0:
            partial_integral += integral[x:, y - 1][:, np.newaxis]

        integral[x:, y:] = partial_integral

    # redraw in color
    img = Image.new("RGB", (width, height), (backgroundweight,backgroundweight,backgroundweight))
    draw = ImageDraw.Draw(img)
    everything = zip(words, font_sizes, positions, orientations)
    for word, font_size, position, orientation in everything:
        font = ImageFont.truetype(font_path, font_size)
        # transpose font optionally
        transposed_font = ImageFont.TransposedFont(font, orientation=orientation)
        draw.setfont(transposed_font)
        draw.text((position[1], position[0]), word, #fill = "red")
                   fill="hsl(%d" % random.randint(0, 50) + ", 80%, 50%)")
    #img.show()
    try:
        img.save(fname)
    except:
        pass
    return img


if __name__ == "__main__":

    x=['qqqqq','wwww','eeee','rrrr','ddddd','hhnhhhh']
    co=[1,2,3,4,5,6]
    from wordcloud import  make_wordcloud
    make_wordcloud(x,co,'wordy.jpg')

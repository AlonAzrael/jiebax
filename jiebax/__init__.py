


from cppjieba import JiebaX as JiebaX, JiebaXTextRank as TextRankWords

# print "import jiebax"
# class JiebaX():

#     def __init__(self, dict_path=None, model_path=None, user_dict_path=""):
#         pass

import re

class TextUtils(object):

    def __init__(self):
        self.tag_re = re.compile(r'<[^>]+>')

    def remove_tags(self, text, placeholder=""):
        return self.tag_re.sub(placeholder, text)

    def remove_ascii(self, doc, placeholder=r""):
        return re.sub(r'[\x00-\x7F]+',placeholder, doc)

    def remove_non_ascii(self, doc, placeholder=r""):
        return re.sub(r'[^\x00-\x7F]+',placeholder, doc)

    def clean_text_zh(self, text, placeholder=u" "):
        if type(text) != unicode:
            text = unicode(text, "utf-8", "ignore")

        return re.sub(ur"[^\u4e00-\u9fa5\n]+", placeholder, text)



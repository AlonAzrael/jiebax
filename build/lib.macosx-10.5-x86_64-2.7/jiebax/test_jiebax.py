# coding: utf-8

import cppjieba


TEST_DICT_FILEPATH = "./dict.test.txt"
BETTER_DICT_FILEPATH = "./jieba.dict.better.txt"


JIEBAX = cppjieba.JiebaX(dict_path=BETTER_DICT_FILEPATH, model_path="./hmm_model.utf8")

TEST_TEXT = """
“魏则西事件”引发网民对医疗服务和医疗信息商业推广的广泛关注。5月9日，国家网信办会同国家工商总局、国家卫生计生委成立的联合调查组向社会公布了调查结果，提出要求百度做出严格审核商业推广服务、明示推广内容和风险、排名机制调整等多项整改要求。
百度搜索公司总裁宋智孝表示，百度坚决拥护调查组的整改要求，深刻反思自身问题，绝不打一丝折扣。“百度应该提供更加优质、可靠的搜索服务。”“则西同学不幸离世，在社会上引起了巨大反响，也给百度带来极大触动，引发百度全员重新审视作为一家搜索引擎公司的责任。”
作为服务数亿网民，每天响应数十亿次请求的搜索引擎公司，百度搜索已经成为信息社会的基础设施之一。“我们着眼的绝不仅仅是每天处理的海量信息，而更应该将每次点击都视为一次托付和信赖。百度将以这次事件为契机，全面落实整改要求。”宋智孝说。
据介绍，百度将根据调查组的整改要求，从如下六个方面全面落实：
1. 立即全面审查医疗类商业推广服务，对未获得主管部门批准资质的医疗机构坚决不予提供商业推广，同时对内容违规的医疗类推广信息（含药品、医疗器械等）及时进行下线处理。并落实军队有关规定，即日起百度停止包括各类解放军和武警部队医院在内的所有以解放军和武警部队名义进行的商业推广。
2. 对于商业推广结果，改变过去以价格为主的排序机制，改为以信誉度为主，价格为辅的排序机制；
3. 控制商业推广结果数量，对搜索结果页面特别是首页的商业推广信息数量进行严格限制，每页面商业推广信息条数所占比例不超过30%；
4. 对所有搜索结果中的商业推广信息进行醒目标识，进行有效的风险提示；
5. 加强搜索结果中的医疗内容生态建设，建立对医疗内容的评级制度，联合卫计委、中国医学科学院等机构共同提升医疗信息的质量，让网民获得准确权威的医疗信息和服务；
6. 继续提升网民权益保障机制的建设，增设10亿元保障基金，对网民因使用商业推广信息遭遇假冒、欺诈而受到的损失经核定后进行先行赔付。
据介绍，在调查期间，百度公司在联合调查组监督下，已对全部医疗类（含医疗机构、医药器械、药品等）机构的资质进行了重新审核，对2518家医疗机构、1.26亿条推广信息实现了下线处理。百度将在5月31日之前，落实以上整改要求，并接受监管部门和广大网民的后续监督。
宋智孝表示，此次联合调查组进驻，给予百度很多业务指导意见，帮助我们审视问题、改进管理。这次整改会对百度的短期利益造成影响，但我们相信在调查组的指导下，百度和搜索引擎行业能够实现更健康的发展，广大网民的权益会得到更好的保障，还将大力推动医疗服务质量的提升。
“百度最新成立搜索公司，有信心、有决心以此为新征程、新起点，与不良信息进行长期的坚决斗争，为广大用户提供更简单、更便捷、更值得依赖的搜索服务。”宋智孝表示。
"""

def import_jieba():
    from jieba import Tokenizer
    dt = Tokenizer(dictionary=BETTER_DICT_FILEPATH)
    dt.initialize()

    return dt


def import_jieba_posseg(dt=None):
    from jieba.posseg import POSTokenizer
    dt_pos = POSTokenizer(tokenizer=dt)

    return dt_pos


def small_test():
    for word, pos in  JIEBAX.posseg_nav("你好，世界杯。地球欢迎你旋转，跳街舞。", return_pair=True):
        print word, pos


def _convert_blood_parrot():
    with open("./test_txt/blood_parrot.txt", "r") as F:
        content = F.read()
        content = unicode(content, "gbk")

    with open("./test_txt/blood_parrot.utf8.txt", "w") as F:
        F.write(content.encode("utf-8"))


def cut_benchmark(x_flag=True, posseg_flag=True):
    import time

    with open("./test_txt/blood_parrot.utf8.txt", "r") as F:
        content = F.read()
    content = TEST_TEXT

    if not x_flag:
        dt = import_jieba()
        dt_pos = import_jieba_posseg(dt)

    start_time = time.time()

    if x_flag:
        # using jiebax
        if posseg_flag:
            # words = JIEBAX.posseg_filter(content, startswith_list=["n"], ifin_set=set(["a", "v"]), return_pair=False)
            # words = JIEBAX.posseg_nav(content, return_pair=False)
            words = JIEBAX.posseg_filter(content, startswith_list=["n"], ifin_set=set(["a", "v"]), return_pair=False)
        else:
            words = JIEBAX.cut(content)

        print len(words)

    else:
        # using jieba
        if posseg_flag:
            words = []
            for word, tag in dt_pos.cut(content):
            # for word, tag in JIEBAX.posseg(content):
                if tag.startswith("n") or tag == "a" or tag == "v":
                    words.append(word)
        else:
            words = dt.lcut(content)

        print len(words)

    elapsed_time = time.time() - start_time
    print "elapsed time:", elapsed_time

    return words


def keywords_benchmark():
    import time

    with open("./test_txt/blood_parrot.utf8.txt", "r") as F:
        content = F.read()

    # content = TEST_TEXT

    textrank = cppjieba.JiebaXTextRank(JIEBAX)

    words = JIEBAX.posseg_nav(content, return_pair=False)
    # print len(words)

    start_time = time.time()

    for word, weight in textrank.extract_by_words(words, max_words=50):
        print word, weight

    elapsed_time = time.time() - start_time
    print "elapsed time:", elapsed_time


def print_words(words):
    if type(words[0]) == list:
        for word in words:
            for x in word:
                print x,
            print ""
    else:
        for word in words:
            print word


if __name__ == '__main__':
    # _convert_blood_parrot()
    # words = cut_benchmark(x_flag=True, posseg_flag=False)
    # print_words(list(set(words))) 
    keywords_benchmark()



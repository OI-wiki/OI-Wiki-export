import os
import sys
import yaml


path = ""

def getTitle(title):
    title = title.replace(" ","")
    title = title.replace("/","")
    title = title.replace("&","")
    title = title.replace("-","")
    title = title.replace("|","")
    title = title.replace("(","（")
    title = title.replace(")","）")
    
    return title

def dfs(root, title):
    if(isinstance(root, list)):
        for x in root:
            dfs(x, "")
    elif (isinstance(root, dict)):
        for k,v in root.items():
            dfs(v, k)
            if(isinstance(v, list)):
                # print(k)
                title = getTitle(k)
                # print("title = ", title)
                order = "python3 ./EpubMerge/epubmerge.py --title=" + title + " "
                for pair in v:
                    subTitle = getTitle(next(iter(pair)))
                    subValue = pair[next(iter(pair))]
                    if(isinstance(subValue, list)):
                        dest_file = path + "./tmpdir/" + subTitle + ".epub"
                        order = order + dest_file + " "
                    else:
                        str = path +"./docs/"+subValue
                        slash_pos = str.rfind("/")
                        resource_path = str[:slash_pos + 1]
                        dest_file =  resource_path + subTitle + ".epub"
                        order = order + dest_file + " "
                order = order + "-o " + path + "./tmpdir/" + title + ".epub"
                # print(order)
                os.system(order)

    else:
        str = path + "./docs/"+root
        slash_pos = str.rfind("/")
        title = getTitle(title)
        resource_path = str[:slash_pos + 1]
        dest_file =  resource_path + title + '.epub'

        order = "pandoc --webtex=http://127.0.0.1:8888/svg.latex? --self-contained --resource-path "+ resource_path +" --metadata title=" + title + " -f markdown+tex_math_dollars "+ str +" -o " + dest_file

        # print(order)
        os.system(order)
        

# 处理文件路径
if(len(sys.argv) == 2):
    path = sys.argv[1] 
print(path)

# 处理OI-wiki的格式
nowPath = os.getcwd()
print(nowPath)
os.chdir(path)
newPath = os.getcwd()
os.system("npm i")
os.system("npm install git://github.com/OI-wiki/remark-details.git#export_epub")
os.system("npx remark . -o")
os.chdir(nowPath)

# 处理yaml内容
os.system("mkdir -p " + path + "tmpdir")
f1 = open(path+"mkdocs.yml")
f2 = open(path+"mkdocs_tmp.yml", "w")
lines = f1.readlines()
for line in lines:
    if(line.find("Theme") != -1):
        break
    f2.write(line)
f2.close()
f2 = open(path+"mkdocs_tmp.yml")

# print (os.getcwd())
y = yaml.safe_load(f2)
nav = y['nav']
# print(nav)
dfs(nav, "")
order = "python3 ./EpubMerge/epubmerge.py --title=" + "OI-Wiki" + " "
for pair in nav:
    # print(pair)
    subTitle = getTitle(next(iter(pair)))
    dest_file = path + "./tmpdir/" + subTitle + ".epub"
    order = order + dest_file + " "
order = order + "-o " + path + "./tmpdir/OI-Wiki.epub"
print(order)
os.system(order)
os.system("cp " + path + "tmpdir/OI-Wiki.epub ./OI-Wiki.epub")

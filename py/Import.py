#!/usr/bin/env python
# encoding: utf-8

# 配置clang检查器 

# 执行脚本时传入两个参数 
# 1.目标target 的数组下标 例如第一个target 则传入 0
# 2.xcode项目对应的pbxproj文件路径

# 例如 
# python SetupChecker.py 0 /Users/chenjd/Desktop/PythonHelperTest/PythonTest/PythonTest.xcodeproj/project.pbxproj

from PBXProjectHelper import *

def main():
	sys.setdefaultencoding('utf-8')

	if  len (sys.argv) > 1 :
        	print "\nimport start >>>>>>>>>>>>>>>>>>>>>>>>>\n"
        	mainTargetIndex = sys.argv[1]
                testTargetIndex = sys.argv[2]
                pbxPath = sys.argv[3]
                fmPath = sys.argv[4]
                mmPath = sys.argv[5]

                print "mainTargetIndex = %s" %mainTargetIndex
                print "testTargetIndex = %s" %testTargetIndex
                print "pbxPath = %s" %pbxPath
                print "fmPath = %s" %fmPath
                print "mmPath = %s" %mmPath

        	#配置 Clang 插件
        	parser = PBXProjectHelper(pbxPath)

        	frameworkTarget = parser.project.targets[int(mainTargetIndex)]
                sourcesTarget = parser.project.targets[int(testTargetIndex)]

                #加入.mm文件
                parser.project.mainGroup.addFile(mmPath, sourcesTarget)
                #加入framework
                parser.project.mainGroup.addFramework(fmPath, frameworkTarget)

        	parser.save()

        	print "\nimport end >>>>>>>>>>>>>>>>>>>>>>>>>>\n"

if __name__ == "__main__":
	sys.exit(main())

	
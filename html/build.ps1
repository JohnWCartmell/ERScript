echo ("*** building from  source $SOURCE html folder")

attrib -R $TARGET\index.html
copy-item $SOURCE\html\index.html -Destination $TARGET
attrib +R $TARGET\index.html

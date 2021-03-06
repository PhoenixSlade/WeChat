//
//  WeChatCustomKeyBord.swift
//  WeChat
//
//  Created by Smile on 16/1/27.
//  Copyright © 2016年 smile.love.tao@gmail.com. All rights reserved.
//

import UIKit

//自定义聊天键盘
class WeChatCustomKeyBordView: UIView,UITextViewDelegate{

    var bgColor:UIColor!
    var isLayedOut:Bool = false
    
    var topView:UIView!
    var textView:PlaceholderTextView!//多行输入
    let topOrBottomPadding:CGFloat = 7//上边空白
    let leftPadding:CGFloat = 10//左边空白
    let kAnimationDuration:NSTimeInterval = 0.2//动画时间
    var biaoQing:UIImageView!
    let biaoQingPadding:CGFloat = 15
    var isBiaoQingDialogShow:Bool = false//是否显示表情对话框
    var biaoQingDialog:WeChatEmojiDialogView?
    var defaultHeight:CGFloat = 47//默认高度
    let biaoQingHeight:CGFloat = 220//表情对话框高度
    var delegate:WeChatEmojiDialogBottomDelegate?
    var height:CGFloat = 0//总高度
    var textViewHeight:CGFloat = 0//textView高度
    var textViewWidth:CGFloat = 0//textView宽度
    let defaultLine:Int = 4
    var placeholderText:String?
    
    init(placeholderText:String?){
        self.height = UIScreen.mainScreen().bounds.height - defaultHeight
        let frame = CGRectMake(0, self.height, UIScreen.mainScreen().bounds.width, defaultHeight)
        super.init(frame: frame)
        
        if placeholderText != nil {
            if !placeholderText!.isEmpty {
                self.placeholderText = placeholderText
            }
        }
        
        //定义通知,获取键盘高度
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARKS: 键盘弹起事件的时候隐藏表情对话框
    func keyboardWillAppear(notification: NSNotification) {
        let keyboardInfo = notification.userInfo![UIKeyboardFrameEndUserInfoKey]
        let keyboardHeight:CGFloat = (keyboardInfo?.CGRectValue.size.height)!
        
        /*
        //键盘偏移量
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.floatValue
        let beginKeyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        let endKeyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let yOffset = endKeyboardRect!.origin.y - beginKeyboardRect!.origin.y*/

        //隐藏表情对话框
        if self.biaoQingDialog != nil {
            if isBiaoQingDialogShow {
                self.biaoQingDialog?.removeFromSuperview()
                self.biaoQing.image = UIImage(named: "rightImg")
                isBiaoQingDialogShow = false
            }
            
        }
        
        animation(self.frame.origin.x, y: UIScreen.mainScreen().bounds.height - self.topOrBottomPadding * 2 - self.textView.frame.height - keyboardHeight)
    }
    
    //MARKS: 键盘落下事件
    func keyboardWillDisappear(notification:NSNotification){
        if self.textView != nil {
            animation(self.frame.origin.x, y: UIScreen.mainScreen().bounds.height - self.topOrBottomPadding * 2 - self.textView.frame.height)
        }
    }
    
    //MARKS: 导航条返回
    func navigationBackClick(){
        self.frame.origin = CGPointMake(self.frame.origin.x,UIScreen.mainScreen().bounds.height - self.frame.height)
        self.textView.resignFirstResponder()
    }
    
    //MARKS: TextView动画
    func animation(x:CGFloat,y:CGFloat){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kAnimationDuration)
        self.frame.origin = CGPointMake(x, y)
        UIView.commitAnimations()
    }
    
    func animation(rect:CGRect){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kAnimationDuration)
        self.frame = rect
        UIView.commitAnimations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLayedOut {
            self.backgroundColor = UIColor.whiteColor()
            create()
            self.textView.resignFirstResponder()
            self.isLayedOut = true
        }
    }
    
    func create(){
        createLineOnTop()
        createTopView()
    }
    
    //MARKS: 创建顶部view
    func createTopView(){
        //创建输入框
        createTextView()
        //创建输入框边上的表情
        createBiaoQing()
        self.topView = UIView()
        topView.frame = CGRectMake(0, 0, self.frame.width, defaultHeight)
        topView.addSubview(self.textView)
        topView.addSubview(self.biaoQing)
        self.addSubview(topView)
    }
    
    //MARKS: 创建TextView
    func createTextView(){
        self.textViewHeight = defaultHeight - topOrBottomPadding * 2
        self.textViewWidth = UIScreen.mainScreen().bounds.width - leftPadding - biaoQingPadding * 2 - self.textViewHeight
        let frame = CGRectMake(leftPadding, topOrBottomPadding,self.textViewWidth, textViewHeight)
        
        self.textView = PlaceholderTextView(frame: frame,placeholder: self.placeholderText,color: nil,font: nil)
        self.textView.layer.borderWidth = 0.5  //边框粗细
        self.textView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).CGColor //边框颜色
        self.textView.editable = true//是否可编辑
        self.textView.selectable = true//是否可选
        self.textView.dataDetectorTypes = .None//给文字中的电话号码和网址自动加链接,这里不需要添加
        self.textView.returnKeyType = .Done
        self.textView.font = UIFont(name: "AlNile", size: 16)
        //设置不可以滚动
        self.textView.showsVerticalScrollIndicator = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.autoresizingMask = .FlexibleHeight
        //不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
        self.textView.scrollEnabled = false
        self.textView.scrollsToTop = false
        //设置圆角
        self.textView.layer.cornerRadius = 4
        self.textView.layer.masksToBounds = true
        self.textView.delegate = self
        //self.textView.selectedRange = NSMakeRange(0,0) ;   //起始位置
        
        //设置行距
        /*let style = NSMutableParagraphStyle()
        style.lineSpacing = 8//行距
        let attributes:NSDictionary = NSDictionary(object: style, forKey: NSParagraphStyleAttributeName)
        self.textView.attributedText = NSAttributedString(string: self.textView.text, attributes: attributes as? [String : AnyObject])*/
    }
    
    //MARKS: 创建输入框边上的表情
    func createBiaoQing(){
        self.biaoQing = UIImageView()
        self.biaoQing.frame = CGRectMake(self.textView.frame.origin.x + self.textView.frame.width + self.biaoQingPadding, self.textView.frame.origin.y, self.textView.frame.height, self.textView.frame.height)
        self.biaoQing.image = UIImage(named: "rightImg")
        self.biaoQing.userInteractionEnabled = true
        self.biaoQing.addGestureRecognizer(WeChatUITapGestureRecognizer(target: self, action: "createBiaoQing:"))
    }
    
    //MARKS: 表情点击事件
    func createBiaoQing(gestrue: WeChatUITapGestureRecognizer){
        let imageView = gestrue.view as! UIImageView
        if !isBiaoQingDialogShow {
            imageView.image = UIImage(named: "rightImgChange")
            isBiaoQingDialogShow = true
            self.textView.resignFirstResponder()
            
            let frameBeginY:CGFloat = UIScreen.mainScreen().bounds.height - self.biaoQingHeight - self.textView.frame.height - topOrBottomPadding * 2
            animation(CGRectMake(self.frame.origin.x,frameBeginY , UIScreen.mainScreen().bounds.width, self.defaultHeight + biaoQingHeight))
            if biaoQingDialog != nil {
                self.biaoQingDialog?.removeFromSuperview()
            }
            
            let labelHeight:CGFloat = getTextViewTextBoundingHeight(self.textView.text)
            let numLine:Int = Int(ceil(labelHeight / getOneCharHeight()))
            
            //添加表情对话框
            var beginY:CGFloat = 0
            if numLine == 1 {
               beginY = self.textView.frame.origin.y + self.textView.frame.height - self.topOrBottomPadding * 2
            } else if numLine > 1 {
                beginY = self.frame.height - self.biaoQingHeight + topOrBottomPadding + 5
            }
            
            
            biaoQingDialog = WeChatEmojiDialogView(frame: CGRectMake(0,beginY, UIScreen.mainScreen().bounds.width,biaoQingHeight),keyboardView:self)
            self.addSubview(biaoQingDialog!)
            self.bringSubviewToFront(biaoQingDialog!)
            self.biaoQingDialog?.delegate = self.delegate
            
        } else {
            imageView.image = UIImage(named: "rightImg")
            isBiaoQingDialogShow = false
            self.textView.resignFirstResponder()
            if self.biaoQingDialog != nil {
                self.biaoQingDialog?.removeFromSuperview()
            }
            
            animation(CGRectMake(self.frame.origin.x, UIScreen.mainScreen().bounds.height - self.topOrBottomPadding * 2 - self.textView.frame.height, UIScreen.mainScreen().bounds.width, self.textView.frame.height + self.topOrBottomPadding * 2))
        }
    }
    
    
    //MARKS: 顶部画线
    func createLineOnTop(){
        let shape = WeChatDrawView().drawLine(beginPointX: 0, beginPointY: 0, endPointX: self.frame.width, endPointY: 0,color:UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1))
        shape.lineWidth = 0.2
        self.layer.addSublayer(shape)
    }
    
    //MARKS: 自定义选择内容后的菜单
    func addSelectCustomMenu(){
        
    }
    
    func getOneCharHeight() ->CGFloat{
        return getTextViewTextBoundingHeight("我")
    }
    
    //MARSK: 去掉回车,限制UITextView的行数
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textView.resignFirstResponder()
            return false
        }
        
        let labelHeight:CGFloat = getTextViewTextBoundingHeight(self.textView.text + text)
        let numLine:Int = Int(ceil(labelHeight / getOneCharHeight()))
        if numLine > defaultLine {
            self.textView.text = (self.textView.text as NSString).substringToIndex(self.textView.text.characters.count)
            return false
        }
        
        return true
    }
    
    //触摸空白处隐藏键盘
    
    //MARKS: 当空字符的时候重绘placeholder
    func textViewDidChange(textView: UITextView) {
        if textView.text.isEmpty {
            //self.textView.resetCur(self.textView.caretRectForPosition(textView.selectedTextRange!.start))
            self.textView.removeFromSuperview()
            //createTextView()
            self.topView.addSubview(self.textView)
            self.textView.becomeFirstResponder()
        }
        
        //自动增加textView高度
        getTextViewHeight(textView.text)
    }
    
    //MARKS: 获取文字高度
    func getTextViewTextBoundingHeight(text:String) -> CGFloat{
        let contentSize = CGSizeMake(self.textView.frame.width,CGFloat(MAXFLOAT))
        let options : NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        let labelHeight = text.boundingRectWithSize(contentSize, options: options, attributes: [NSFontAttributeName:self.textView.font!], context: nil).size.height
        return labelHeight
    }
    
    var originHeight:CGFloat = 0
    var beginY:CGFloat = 0
    
    //MARKS: 自动增加textView高度
    func getTextViewHeight(text:String){
        if originHeight == 0 {
            originHeight = self.frame.height
            beginY = self.frame.origin.y
        }
        
        let contentSize = CGSizeMake(self.textView.frame.width,CGFloat(MAXFLOAT))
        let labelHeight:CGFloat = getTextViewTextBoundingHeight(text)
        var numLine:Int = 1//显示行数
        numLine = Int(ceil(labelHeight / self.textViewHeight))
        
        var size = self.textView.sizeThatFits(contentSize)
        if numLine > 4 {
            size.height = labelHeight
        }
        
        if labelHeight != self.textView.frame.height && labelHeight > self.textViewHeight{
            //重新设置textView
            textView.frame = CGRectMake(leftPadding, topOrBottomPadding, textViewWidth, size.height)
            
            //重新设置框架frame
            let _padding:CGFloat = size.height - self.textViewHeight
            self.frame = CGRectMake(self.frame.origin.x, beginY - _padding, self.frame.width, originHeight + _padding)
            
            //重新设置biaoQing
            //self.biaoQing.frame = CGRectMake(self.biaoQing.frame.origin.x, self.textView.frame.height - self.topOrBottomPadding - self.biaoQing.frame.height, self.biaoQing.frame.width, self.biaoQing.frame.height)
            
            /*let labelHeight:CGFloat = getTextViewTextBoundingHeight(self.textView.text)
            let numLine:Int = Int(ceil(labelHeight / getOneCharHeight()))
            
            //添加表情对话框
            var _beginY:CGFloat = 0
            if numLine == 1 {
                _beginY = self.textView.frame.origin.y + self.textView.frame.height - self.topOrBottomPadding * 2
            } else if numLine > 1 {
                _beginY = self.frame.height - self.biaoQingHeight + topOrBottomPadding + 5
            }
            
            //重新设置biaoQingDialog
            self.biaoQingDialog?.frame.origin = CGPoint(x: (self.biaoQingDialog?.frame.origin.x)!, y: _beginY)*/
        }
    }

}


protocol WeChatEmojiDialogBottomDelegate {
    func addBottom() -> UIView
}

//表情对话框
class WeChatEmojiDialogView:UIView,UIScrollViewDelegate{

    var isLayedOut:Bool = false
    var dialogLeftPadding:CGFloat = 25
    var dialogTopPadding:CGFloat = 15
    var emojiWidth:CGFloat = 32
    var emojiHeight:CGFloat = 32
    var emoji:Emoji!
    var scrollView:UIScrollView!
    var pageControl:UIPageControl!
    var pageCount:Int = 0
    let pageControlHeight:CGFloat = 10
    let onePageCount:Int = 23
    let pageControlWidth:CGFloat = 100
    let bottomHeight:CGFloat = 40
    let bottomTopPadding:CGFloat = 10
    var pageControlBeginY:CGFloat = 0
    var delegate:WeChatEmojiDialogBottomDelegate!
    var bottomView:UIView!
    var keyboardView:WeChatCustomKeyBordView!
    
    init(frame:CGRect,keyboardView:WeChatCustomKeyBordView){
        super.init(frame: frame)
        self.emoji = Emoji()
        //获取页数,向上取整数,如果直接用/会截断取整,需要转成Float
        self.pageCount = Int(ceilf(Float(self.emoji.emojiArray.count) / 23.0))
        self.keyboardView = keyboardView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLayedOut {
            createScrollView()
            self.bottomView = delegate.addBottom()
            self.addSubview(self.bottomView)
            isLayedOut = true
        }
    }
    
    func createScrollView(){
        self.scrollView = UIScrollView()
        self.scrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, self.frame.height - self.bottomHeight)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.scrollsToTop = false
        self.scrollView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 244/255, alpha: 0.2)
        
        createDialog()
        self.addSubview(self.scrollView)
        createPageControl()
    }
    
    //MARKS: 创建PageControl
    func createPageControl(){
        self.pageControl = UIPageControl()
        self.pageControl.frame = CGRectMake((self.frame.width - pageControlWidth) / 2, self.scrollView.frame.origin.y + self.scrollView.frame.height - bottomTopPadding - pageControlHeight, pageControlWidth, pageControlHeight)
        self.pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        self.pageControl.pageIndicatorTintColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
        self.pageControl.numberOfPages = self.pageCount
        self.addSubview(self.pageControl)
        self.bringSubviewToFront(self.pageControl)
    }
    
    func createDialog(){
        //计算padding
        let leftPadding:CGFloat = (self.frame.width - emojiWidth * 8 - dialogLeftPadding * 2) / 7
        let topPadding:CGFloat = (self.scrollView.frame.height - emojiHeight * 3 - dialogTopPadding * 2 - self.bottomTopPadding - self.pageControlHeight) / 2
        var originX:CGFloat = self.dialogLeftPadding
        var originY:CGFloat = self.dialogTopPadding
        let totalCount:Int = emoji.emojiArray.count
        
        var x:CGFloat = 0
        for(var i = 0;i < pageCount;i++){
            let view = UIView()
            view.frame = CGRectMake(x, 0, self.frame.width, self.frame.height - pageControlHeight)
            for(var j = 0;j < totalCount - 1;j++){
                if i * onePageCount + j > (totalCount - 1) {
                    break
                }
                
                let weChatEmoji = emoji.emojiArray[i * onePageCount + j]
                
                let imageView = UIImageView()
                imageView.userInteractionEnabled = true
                
                if j % 8 == 0  && j != 0{
                    originY += (emojiHeight + topPadding)
                    originX =  self.dialogLeftPadding
                }
                
                if j != 0 && j % 8 != 0{
                    originX += (emojiWidth + leftPadding)
                }
                
                imageView.frame = CGRectMake(originX,originY,emojiWidth,emojiHeight)
                
                if (j % onePageCount == 0  && j != 0){
                    
                    imageView.image = UIImage(named: "key-delete")
                    addDeleteViewTap(imageView)
                    if self.pageControlBeginY == 0 {
                        self.pageControlBeginY = originY
                    }
                    
                    originX = self.dialogLeftPadding
                    originY = self.dialogTopPadding
                    view.addSubview(imageView)
                    break
                } else {
                    if (i == pageCount - 1) && (i * onePageCount + j) == (totalCount - 1){
                        imageView.image = UIImage(named: "key-delete")
                    }else{
                        imageView.image = weChatEmoji.image
                    }
                }
                
                addImageViewTap(weChatEmoji, imageView: imageView)
                view.addSubview(imageView)
            }
            
            x += self.frame.width
            self.scrollView.addSubview(view)
        }
    
        
        //为了让内容横向滚动，设置横向内容宽度为N个页面的宽度总和
        //不允许在垂直方向上进行滚动
        self.scrollView.contentSize = CGSizeMake(CGFloat(UIScreen.mainScreen().bounds.width * CGFloat(self.pageCount)), 0)
        self.scrollView.pagingEnabled = true//滚动时只能停留到某一页
        self.scrollView.delegate = self
        self.scrollView.userInteractionEnabled = true
    }

    //MARKS: 图片添加点击事件
    func addImageViewTap(weChatEmoji:WeChatEmoji,imageView:UIImageView){
        let tap = WeChatUITapGestureRecognizer(target:self,action: "imageViewTap:")
        tap.data = []
        tap.data?.append(weChatEmoji.image)
        tap.data?.append(weChatEmoji.key)
        imageView.addGestureRecognizer(tap)
    }
    
    //MARKS:删除事件
    func addDeleteViewTap(imageView:UIImageView){
        let tap = WeChatUITapGestureRecognizer(target:self,action: "imageViewTap:")
        tap.data = []
        tap.data?.append(imageView.image!)
        tap.data?.append("emoji_delete")
        imageView.addGestureRecognizer(tap)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.scrollView == scrollView){
            let current:Int = Int(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width)
            //根据scrollView 的位置对page 的当前页赋值
             self.pageControl.currentPage = current
        }
    }
    
    //MARKS: 图片点击事件
    func imageViewTap(gestrue:WeChatUITapGestureRecognizer){
        //let gestureView = gestrue.view as! UIImageView
        //查找数据
        let weChatView = gestrue.data
        if weChatView != nil && weChatView?.count > 0{
            //let image = weChatView![0]
            let key = weChatView![1] as! String
            
            let text = self.keyboardView.textView.text + key
            let labelHeight:CGFloat = self.keyboardView.getTextViewTextBoundingHeight(text)
            let numLine:Int = Int(ceil(labelHeight / self.keyboardView.getOneCharHeight()))
            if numLine > self.keyboardView.defaultLine {
                return
            }
            if key == "emoji_delete" {//删除键
                deleteText()
            }else {
                self.keyboardView.textView.insertText(key)
            }
        }
    }
    
    //删除文本
    func deleteText(){
        let text = self.keyboardView.textView.text
        if text.isEmpty {
            return
        }
        
        let count:Int = text.characters.count
        
        if count > 2 {
            if text.hasSuffix("]"){
                var index:Int = 3
                
                var isDeleted:Bool = false
                for(var i = 0;i < 3;i++){
                    if i != 0 {
                        index++
                    }
                    
                    let flag = getEmoji(text, count: count, index: index)
                    if flag {
                        isDeleted = true
                        break
                    }
                }
                
                //以上都不匹配,则删除最后一个字符
                if !isDeleted {
                    deleteLastOneChar(text, count: count)
                }
                
            }else{
                deleteLastOneChar(text, count: count)
            }
        }else{
            deleteLastOneChar(text, count: count)
        }
        
        if self.keyboardView.textView.text.isEmpty {
            self.keyboardView.textView.placeholderLabel!.hidden = false
        }
    }
    
    func deleteLastOneChar(text:String,count:Int){
        let oneCharIndex:Int = count - 1
        self.keyboardView.textView.text = (text as NSString).substringWithRange(NSMakeRange(0, oneCharIndex))
    }
    
    func getEmoji(text:String,count:Int,index:Int) -> Bool{
        let oneCharIndex:Int = count - index
        let oneChar = (text as NSString).substringFromIndex(oneCharIndex)
        if emoji.keys.indexOf(oneChar) != nil {
            self.keyboardView.textView.text = (text as NSString).substringWithRange(NSMakeRange(0, oneCharIndex))
            return true
        }
        
        return false
    }
}

enum PlaceholderLocation {
    case Top,Center,Bottom
}

//自定义TextView Placeholder类
class PlaceholderTextView:UITextView,UITextViewDelegate {
    
    var placeholder:String?
    var color:UIColor?
    var fontSize:CGFloat = 18
    
    var placeholderLabel:UILabel?
    var placeholderFont:UIFont?
    var isLayedOut:Bool = false
    var placeholderLabelHeight:CGFloat = 0
    var defaultHeight:CGFloat = 0
    var placeholderLocation:PlaceholderLocation = PlaceholderLocation.Center
    
    
    init(frame:CGRect,placeholder:String?,color:UIColor?,font:UIFont?){
        super.init(frame: frame, textContainer: nil)
        
        self.defaultHeight = frame.height
        
        if placeholder != nil {
            self.placeholder = placeholder
        }
        
        if color != nil {
            self.color = color
        } else {
            self.color = UIColor.lightGrayColor()
        }
        
        if font != nil {
            self.font = font
        } else {
            self.font = UIFont.systemFontOfSize(fontSize)
        }
        
        if self.placeholder != nil && !self.placeholder!.isEmpty {
            initFrame()
        }
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initFrame(){
        self.backgroundColor = UIColor.clearColor()
        self.placeholderLabel = UILabel()
        placeholderLabel!.backgroundColor = UIColor.clearColor()
        placeholderLabel!.numberOfLines = 0//多行
        if self.placeholder != nil {
            placeholderLabel?.text = self.placeholder
        }
        placeholderLabel?.font = self.font
        placeholderLabel?.textColor = self.color
        //根据字体的高度,计算上下空白
        var labelHeight:CGFloat = 0
        let labelWidth:CGFloat = self.frame.width - labelLeftPadding * 2
        let maxSize = CGSizeMake(labelWidth,CGFloat(MAXFLOAT))
        
        let options : NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        labelHeight = self.placeholder!.boundingRectWithSize(maxSize, options: options, attributes: [NSFontAttributeName:self.font!], context: nil).size.height
        
        if placeholderLocation == PlaceholderLocation.Center {
           self.labelTopPadding = (self.frame.height - labelHeight) / 2
        } else if placeholderLocation == PlaceholderLocation.Bottom {
           self.labelTopPadding = self.frame.height - labelHeight
        } else if placeholderLocation == PlaceholderLocation.Top {
           
        }
        
        self.placeholderLabel!.frame = CGRectMake(labelLeftPadding, self.labelTopPadding,labelWidth , labelHeight)
        placeholderLabelHeight = labelHeight
        self.addSubview(placeholderLabel!)
        
        //监听文字变化
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"textDidChange", name: UITextViewTextDidChangeNotification , object: self)
    }
    
    //MARKS: 文字变化
    func textDidChange(){
        self.placeholderLabel!.hidden = self.hasText()//如果UITextView输入了文字,hasText就是YES,反之就为NO
    }
    
    let labelLeftPadding:CGFloat = 7
    var labelTopPadding:CGFloat = 5
    
    
    var curTopPadding:CGFloat = 5
    //MARKS: 设置光标
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        let originalRect = super.caretRectForPosition(position)
        let curHeight:CGFloat = self.defaultHeight - curTopPadding * 3 + 0.5
        return CGRectMake(originalRect.origin.x, originalRect.origin.y, originalRect.width,curHeight)
    }
    
    //MARKS: 重置光标
    /*func resetCur(originalRect:CGRect) -> CGRect{
        var curTopPadding:CGFloat = 5
        let rect = originalRect
        let curHeight:CGFloat = self.defaultHeight - curTopPadding * 2
        if self.frame.height != self.defaultHeight {
            curTopPadding = self.frame.height - curHeight - curTopPadding
        }
        
        return CGRectMake(rect.origin.x, curTopPadding, rect.width, curHeight)
    }*/
    
    
    func textViewDidBeginEditing(textView: UITextView) {
         print("cur focus...")
    }
    
}

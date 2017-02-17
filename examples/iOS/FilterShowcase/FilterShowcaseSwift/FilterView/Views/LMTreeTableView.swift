//
//  LMTreeTableView.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/13.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

import UIKit

class LMTreeNode {
    static let NODE_TYPE_G: Int = 0 //表示该节点不是叶子节点
    static let NODE_TYPE_N: Int = 1 //表示节点为叶子节点
    var type: Int?
    var desc: String? // 对于多种类型的内容，需要确定其内容
    var id: String?
    var pId: String?
    var name: String?
    var level: Int?
    var isExpand: Bool = false
    var icon: String?
    var children: [LMTreeNode] = []
    var parent: LMTreeNode?
    
    init (desc: String?, id:String? , pId: String? , name: String?) {
        self.desc = desc
        self.id = id
        self.pId = pId
        self.name = name
    }
    
    //是否为根节点
    func isRoot() -> Bool{
        return parent == nil
    }
    
    //判断父节点是否打开
    func isParentExpand() -> Bool {
        if parent == nil {
            return false
        }
        return (parent?.isExpand)!
    }
    
    //是否是叶子节点
    func isLeaf() -> Bool {
        return children.count == 0
    }
    
    //获取level,用于设置节点内容偏左的距离
    func getLevel() -> Int {
        return parent == nil ? 0 : (parent?.getLevel())!+1
    }
    
    //设置展开
    func setExpand(isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            var i = 0;
            while i < children.count {
                children[i].setExpand(isExpand: isExpand)
                i += 1
            }
        }
    }
}

private let instance: LMTreeNodeHelper = LMTreeNodeHelper()
class LMTreeNodeHelper{
    // 单例模式
    final class var sharedInstance: LMTreeNodeHelper {
        return instance
    }
    
    //传入普通节点，转换成排序后的Node
    func getSortedNodes(groups: NSMutableArray, defaultExpandLevel: Int) -> [LMTreeNode] {
        var result: [LMTreeNode] = []
        let nodes = convetData2Node(groups: groups)
        let rootNodes = getRootNodes(nodes: nodes)
        for item in rootNodes{
            addNode(nodes: &result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    //过滤出所有可见节点
    func filterVisibleNode(nodes: [LMTreeNode]) -> [LMTreeNode] {
        var result: [LMTreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(node: item)
                result.append(item)
            }
        }
        return result
    }
    
    //将数据转换成书节点
    func convetData2Node(groups: NSMutableArray) -> [LMTreeNode] {
        var nodes: [LMTreeNode] = []
        
        var node: LMTreeNode
        var desc: String?
        var id: String?
        var pId: String?
        var label: String?
        
        for item in groups {
            let itemInfo = item as! Dictionary<String, String>
            desc = itemInfo["description"]
            id = itemInfo["id"]
            pId = itemInfo["pid"]
            label = itemInfo["name"]
            
            node = LMTreeNode(desc: desc, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        
        /**
         * 设置Node间，父子关系;让每两个节点都比较一次，即可设置其中的关系
         */
        var n: LMTreeNode
        var m: LMTreeNode
        
        for i in 0..<nodes.count {
            n = nodes[i]
            for j in i+1..<nodes.count {
                m = nodes[j]
                if m.pId == n.id {
                    n.children.append(m)
                    m.parent = n
                } else if n.pId == m.id {
                    m.children.append(n)
                    n.parent = m
                }
            }
        }
        for item in nodes {
            setNodeIcon(node: item)
        }
        
        return nodes
    }
    
    // 获取根节点集
    func getRootNodes(nodes: [LMTreeNode]) -> [LMTreeNode] {
        var root: [LMTreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    //把一个节点的所有子节点都挂上去
    func addNode( nodes: inout [LMTreeNode], node: LMTreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(isExpand: true)
        }
        if node.isLeaf() {
            return
        }
        var i = 0
        while i<node.children.count {
            addNode(nodes: &nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
            i+=1
        }
    }
    
    // 设置节点图标
    func setNodeIcon(node: LMTreeNode) {
        if node.children.count > 0 {
            node.type = LMTreeNode.NODE_TYPE_G
            if node.isExpand {
                // 设置icon为向下的箭头
                node.icon = "tree_ex.png"
            } else if !node.isExpand {
                // 设置icon为向右的箭头
                node.icon = "tree_ec.png"
            }
        } else {
            node.type = LMTreeNode.NODE_TYPE_N
        }
    }
}

class LMTreeNodeTableViewCell: UITableViewCell {
    private var _node:LMTreeNode?
    var node: LMTreeNode? {
        get {
            return _node
        }
        set {
            _node = newValue
            if _node != nil {
                if _node?.type == LMTreeNode.NODE_TYPE_G {
                    self.imageView?.image = UIImage(named: (_node?.icon)!)
                    self.imageView?.contentMode = .center
                }else{
                    self.imageView?.image = nil
                }
                self.textLabel?.text = _node?.name
                self.detailTextLabel?.text = _node?.desc
                let indentLevel : Int = Int((self.node?.getLevel())!) + 1
                /*if self.responds(to: #selector(setter: UIView.layoutMargins)) {
                 var margins : UIEdgeInsets = self.layoutMargins
                 margins.left = 60 * insets
                 self.layoutMargins = margins
                 
                 }else */
                
                self.indentationLevel = indentLevel
                self.indentationWidth = 0
                if self.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
                    var sepInset : UIEdgeInsets = self.separatorInset
                    sepInset.left = CGFloat(16 * indentLevel)
                    self.separatorInset = sepInset
                }
                
                self.setNeedsDisplay()
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:.subtitle, reuseIdentifier: reuseIdentifier)
        let accessoryImageView:UIImageView = UIImageView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 20, height: 20)))
        accessoryImageView.image = #imageLiteral(resourceName: "Lambeau.jpg")
        self.accessoryView = accessoryImageView
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LMTreeTable : UITableView,UITableViewDelegate,UITableViewDataSource {
    var mAllNodes: [LMTreeNode]? //所有的node
    var mNodes: [LMTreeNode]? //可见的node
    
    let NODE_CELL_ID: String = "nodecell"
    
    static var sharedInstance : LMTreeTable {
        struct Static {
            static let instance : LMTreeTable = LMTreeTable(frame: CGRect.zero, withData: LMTreeNodeHelper.sharedInstance.getSortedNodes(groups: NSMutableArray(contentsOfFile: Bundle.main.path(forResource: "DataSources", ofType: "plist")!)!, defaultExpandLevel: 0))
        }
        return Static.instance
    }
    
    init(frame: CGRect, withData data: [LMTreeNode]) {
        super.init(frame: frame, style: .grouped)
        self.register(LMTreeNodeTableViewCell.self, forCellReuseIdentifier: NODE_CELL_ID)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        mNodes = LMTreeNodeHelper.sharedInstance.filterVisibleNode(nodes: mAllNodes!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LMTreeNodeTableViewCell = tableView.dequeueReusableCell(withIdentifier: NODE_CELL_ID) as! LMTreeNodeTableViewCell
        let node: LMTreeNode = mNodes![indexPath.row]
        //        if node.type == LMTreeNode.NODE_TYPE_G {
        //            cell.imageView?.contentMode = .center
        //            cell.imageView?.image = UIImage(named: (node.icon)!)
        //        }else{
        //            cell.imageView?.image = nil
        //        }
        //        
        //        cell.textLabel?.text = node.name
        //        cell.detailTextLabel?.text = node.desc
        
        cell.node = node
        //        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mNodes?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    /* 设置缩进
     func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
     let node: LMTreeNode = mNodes![indexPath.row]
     return Int(node.getLevel())
     }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {// 点击的节点为叶子节点
            // do something
            return
        }
        
        expandOrCollapse(count: &endPosition, node: parentNode)
        mNodes = LMTreeNodeHelper.sharedInstance.filterVisibleNode(nodes: mAllNodes!) //更新可见节点
        
        //修正indexpath
        var indexPathArray :[IndexPath] = []
        var tempIndexPath: IndexPath?
        for i in startPosition..<endPosition {
            tempIndexPath = IndexPath(row: i, section: 0)
            indexPathArray.append(tempIndexPath!)
        }
        self.beginUpdates()
        // 插入和删除节点的动画
        if parentNode.isExpand {
            self.insertRows(at: indexPathArray as [IndexPath], with: .bottom)
        } else {
            self.deleteRows(at: indexPathArray as [IndexPath], with: .top)
        }
        self.endUpdates()
        
        //更新被选组节点
        //self.reloadRows(at: [indexPath as IndexPath], with: .none)
    }
    
    //展开或者关闭某个节点
    func expandOrCollapse( count: inout Int, node: LMTreeNode) {
        if node.isExpand { //如果当前节点是开着的，需要关闭节点下的所有子节点
            closedChildNode(count: &count,node: node)
        } else { //如果节点是关着的，打开当前节点即可
            count += node.children.count
            node.setExpand(isExpand: true)
        }
        
    }
    
    //关闭某个节点和该节点的所有子节点
    func closedChildNode( count:inout Int, node: LMTreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { //关闭子节点
                count += 1 // 计算子节点数加一
                closedChildNode(count: &count, node: item)
            }
        }
    }
}

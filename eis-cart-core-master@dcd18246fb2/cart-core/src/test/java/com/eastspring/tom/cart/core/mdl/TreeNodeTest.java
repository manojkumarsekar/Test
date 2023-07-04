package com.eastspring.tom.cart.core.mdl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.CartCoreUtlConfig;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class TreeNodeTest {
    private TreeNode<String> root;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(TreeNodeTest.class);
    }

    @Before
    public void setUp() {
        root = new TreeNode<>("rootTest");
    }

    private void constructTree1() {
        // construct a tree1:
        //   root
        //     +-- andy
        //     |     +--- donny
        //     |     +--- eric
        //     +-- benny
        //     +-- charlie
        //           +--- foodie
        //           +--- gummy
        //                  +--- yummy

        TreeNode<String> andy = root.addChild("andy");
        root.addChild("benny");
        TreeNode<String> charlie = root.addChild("charlie");
        andy.addChild("donny");
        andy.addChild("eric");
        charlie.addChild("foodie");
        TreeNode<String> gummy = charlie.addChild("gummy");
        gummy.addChild("yummy");
    }

    @Test
    public void testAddChildren() {
        List<TreeNode<String>> children0 = root.getChildren();
        assertNotNull(children0);
        assertEquals(0, children0.size());

        List<TreeNode<String>> children1 = root.getChildren();
        TreeNode<String> andyNode1 =  root.addChild("andy");
        assertEquals("andy", andyNode1.getData());
        assertNotNull(children1);
        assertEquals(1, children1.size());
        TreeNode<String> andyNode2 = children1.get(0);
        assertEquals("andy", andyNode2.getData());
        assertEquals(andyNode1, andyNode2);

        List<TreeNode<String>> children2 = root.getChildren();
        TreeNode<String> bennyNode1 = root.addChild("benny");
        assertEquals("benny", bennyNode1.getData());
        assertNotNull(children2);
        assertEquals(2, children2.size());
        TreeNode<String> bennyNode2 = children2.get(1);
        assertEquals("andy", children2.get(0).getData());
        assertEquals("benny", bennyNode2.getData());
        assertEquals(bennyNode1, bennyNode2);

        List<TreeNode<String>> children3 = root.getChildren();
        TreeNode<String> charlieNode1 = root.addChild("charlie");
        assertEquals("charlie", charlieNode1.getData());
        assertNotNull(children3);
        assertEquals(3, children3.size());
        TreeNode<String> charlieNode2 = children3.get(2);
        assertEquals("andy", children3.get(0).getData());
        assertEquals("benny", children3.get(1).getData());
        assertEquals("charlie", charlieNode2.getData());
        assertEquals(charlieNode1, charlieNode2);
    }

    @Test
    public void testTreeConstruction() {
        constructTree1();
        assertNotNull(root);
        List<TreeNode<String>> rootChildren = root.getChildren();
        assertEquals(3, rootChildren.size());
        TreeNode<String> andyNode = rootChildren.get(0);
        assertEquals("andy", andyNode.getData());
        assertEquals("benny", rootChildren.get(1).getData());
        TreeNode<String> charlieNode = rootChildren.get(2);
        assertEquals("charlie", charlieNode.getData());
        List<TreeNode<String>> andyChildren = andyNode.getChildren();
        assertEquals(2, andyChildren.size());
        assertEquals("donny", andyChildren.get(0).getData());
        assertEquals("eric", andyChildren.get(1).getData());
        List<TreeNode<String>> charlieChildren = charlieNode.getChildren();
        assertEquals(2, charlieChildren.size());
        assertEquals("foodie", charlieChildren.get(0).getData());
        TreeNode<String> gummyNode = charlieChildren.get(1);
        assertEquals("gummy", gummyNode.getData());
        List<TreeNode<String>> gummyChildren = gummyNode.getChildren();
        assertEquals(1, gummyChildren.size());
        assertEquals("yummy", gummyChildren.get(0).getData());
    }
}

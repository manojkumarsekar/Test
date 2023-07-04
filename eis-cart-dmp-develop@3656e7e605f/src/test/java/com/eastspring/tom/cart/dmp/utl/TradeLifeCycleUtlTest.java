/*package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.Formats;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.svc.RuntimeRemoteSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import org.joda.time.DateTime;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathExpressionException;
import java.io.IOException;

import static com.eastspring.tom.cart.constant.Formats.TRADE_NUGGET_PATTERN;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_SERVER;
import static com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl.GET_NUGGET_COMMAND;
import static com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl.GET_TRANSACTION_COMMAND;
import static com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl.NUGGET_POLLING_INTERVAL;
import static com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl.TLC_NUGGET_WAIT_SECONDS;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class TradeLifeCycleUtlTest {

    @InjectMocks
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private FormatterUtil formatterUtil;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private DateTimeUtil dateTimeUtil;

    @Mock
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Mock
    private XPathUtil xPathUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetTradeNuggetName() {
        String host = "host";
        int port = 22;
        String user = "user";
        String timestamp = "Thu 14 Feb 2019 12:00:00";
        String pattern = "eis_ADX.I.*";

        RemoteOutput output = new RemoteOutput("esi_ADX.I", "");

        when(stateSvc.getStringVar(TLC_SERVER + ".host")).thenReturn(host);
        when(stateSvc.getStringVar(TLC_SERVER + ".port")).thenReturn(String.valueOf(port));
        when(stateSvc.getStringVar(TLC_SERVER + ".user")).thenReturn(user);
        when(stateSvc.getStringVar(TLC_NUGGET_WAIT_SECONDS)).thenReturn("10");

        when(formatterUtil.format(TRADE_NUGGET_PATTERN, Formats.BRS_TRADE_NUGGET_TIMESTAMP.print(new DateTime()))).thenReturn(pattern);

        when(runtimeRemoteSvc.getTimeStamp(host, port, user, null)).thenReturn(timestamp);
        when(formatterUtil.format(GET_NUGGET_COMMAND, "/dmp/archive/in/brs/intraday", timestamp, pattern, "<INVNUM>-14</INVNUM>")).thenReturn("command");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(0L);
        when(runtimeRemoteSvc.sshRemoteExecute(host, port, user, "command")).thenReturn(output);

        tradeLifeCycleUtl.getTradeNuggetName("/dmp/archive/in/brs/intraday", "<INVNUM>-14</INVNUM>");
        verify(threadSvc, times(0)).sleepSeconds(NUGGET_POLLING_INTERVAL);
        verify(dateTimeUtil, times(2)).currentTimeMillis();
    }

    @Test
    public void testGetTradeNuggetName_NuggetNotFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Cannot find BrsTrade Nugget with value [<INVNUM>-14</INVNUM>]");
        String host = "host";
        int port = 22;
        String user = "user";
        String timestamp = "Thu 14 Feb 2019 12:00:00";
        String pattern = "eis_ADX.I.*";

        RemoteOutput output = new RemoteOutput("", "");

        when(stateSvc.getStringVar(TLC_SERVER + ".host")).thenReturn(host);
        when(stateSvc.getStringVar(TLC_SERVER + ".port")).thenReturn(String.valueOf(port));
        when(stateSvc.getStringVar(TLC_SERVER + ".user")).thenReturn(user);
        when(stateSvc.getStringVar(TLC_NUGGET_WAIT_SECONDS)).thenReturn("0");

        when(formatterUtil.format(TRADE_NUGGET_PATTERN, Formats.BRS_TRADE_NUGGET_TIMESTAMP.print(new DateTime()))).thenReturn(pattern);

        when(runtimeRemoteSvc.getTimeStamp(host, port, user, null)).thenReturn(timestamp);
        when(formatterUtil.format(GET_NUGGET_COMMAND, "/dmp/archive/in/brs/intraday", timestamp, pattern, "<INVNUM>-14</INVNUM>")).thenReturn("command");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(1000L).thenReturn(2000L);

        when(runtimeRemoteSvc.sshRemoteExecute(host, port, user, "command")).thenReturn(output);

        tradeLifeCycleUtl.getTradeNuggetName("/dmp/archive/in/brs/intraday", "<INVNUM>-14</INVNUM>");
        verify(threadSvc, times(1)).sleepSeconds(NUGGET_POLLING_INTERVAL);
        verify(dateTimeUtil, times(2)).currentTimeMillis();
    }

    @Test
    public void testGetTradeData() throws ParserConfigurationException, IOException, SAXException, XPathExpressionException {
        String host = "host";
        int port = 22;
        String user = "user";
        String xml = "<TRADE><A>1</A><B><ID1>2</ID1></B></TRADE>";
        String tradeNuggetPath = "/dmp/archive/in/brs/intraday";
        String s = "esi_ADX_I.20190214_060407_00008.tar.gz";
        String expression = "//ID1[text()='2']//ancestor::B";

        when(stateSvc.getStringVar(TLC_SERVER + ".host")).thenReturn(host);
        when(stateSvc.getStringVar(TLC_SERVER + ".port")).thenReturn(String.valueOf(port));
        when(stateSvc.getStringVar(TLC_SERVER + ".user")).thenReturn(user);

        when(formatterUtil.format(GET_TRANSACTION_COMMAND, tradeNuggetPath, s)).thenReturn("Mock command");
        when(runtimeRemoteSvc.sshRemoteExecute(host, port, user, "Mock command")).thenReturn(new RemoteOutput(xml, ""));

        when(xPathUtil.extractByNode(xPathUtil.getXMLNodeByXpath(xml, expression))).thenReturn("<B><ID1>2</ID1></B>");

        String tradeData = tradeLifeCycleUtl.getActualTradeData(tradeNuggetPath, s, expression);
        Assert.assertEquals("<B><ID1>2</ID1></B>", tradeData);

    }
}
*/
package com.eastspring.tom.cart.constant;

public final class CommonLocators {

    private CommonLocators() {
    }

    public static final String GS_VALIDATION_ERROR_COUNT_MSG = "xpath://span[@class='redColor' and starts-with(text(),'Found') and contains(text(),'validation error(s).')]";
    public static final String GS_VALIDATION_ERROR_LINK = GS_VALIDATION_ERROR_COUNT_MSG + "/ancestor::div[@role='button']";
    public static final String GS_VALIDATION_ERROR_TABLE = GS_VALIDATION_ERROR_COUNT_MSG + "/ancestor::div[contains(@class,'v-panel-content')]//table[@class='v-table-table']";

    public static final String VARIABLE = "${";

    public static final String GS_HEADER_TABLE_XPATH = "//div[@class='v-table-header-wrap']//table/tbody";
    public static final String GS_DATA_TABLE_XPATH = "//table[@class='v-table-table']/tbody";
    public static final String GS_LOOKUP_SEARCH_DATA_TABLE_XPATH = "//div[@role='dialog']" + GS_DATA_TABLE_XPATH;

    public static final String XPATH = "xpath:";
    public static final String GS_DATA_TABLE_ROW = XPATH + GS_DATA_TABLE_XPATH + "/tr/td/div[text()='%s']";
    public static final String GS_LOOKUP_SEARCH_TEXT_FIELD = "xpath://div[@class='filters-panel']/div[contains(@class,'filterwrapper')][%d]/input";
    public static final String GS_LOOKUP_SEARCH_DROPDOWN_TEXTFIELD = "xpath://div[@class='filters-panel']/div[contains(@class,'filterwrapper')][%d]/div/input";


    public static final String GS_ACTIVE_TAB = "xpath://div[contains(@class,'gsActiveTab')]";
    public static final String GS_SEARCH_TEXT_FIELD = "xpath://div[@class='filters-panel']/div[contains(@class,'filterwrapper')][%d]/input";
    public static final String GS_SPLITTER = "xpath://div[contains(@class,'v-button-link gsSplitter')]";

    public static final String GS_HOME_USER_MENU = "xpath://span[contains(@class,'gsUserMenu')]/..";
    public static final String GS_SAVE_BUTTON = "xpath://div[contains(@class,'secondToolbar')]//span[text()='Save']/../..";
    public static final String GS_RELOAD_BUTTON = "xpath://div[contains(@class,'secondToolbar')]//span[text()='Reload']/../..";
    public static final String GS_OTHERS_MENU_BUTTON = "xpath://div[contains(@class,'secondToolbar')]//span[text()='Others']/../..";
    public static final String GS_OTHERS_DELETE_BUTTON = "xpath://div[contains(@class,'v-menubar-submenu')]//span[text()='Delete']/..";
    public static final String GS_OTHERS_LOCK_BUTTON = "xpath://div[contains(@class,'v-menubar-submenu')]//span[text()='Lock']/..";
    public static final String GS_OTHERS_UNLOCK_BUTTON = "xpath://div[contains(@class,'v-menubar-submenu')]//span[text()='UnLock']/..";


    public static final String GS_SETUP_BUTTON = "xpath://div[contains(@class,'gsSearchToolbar')]//span[text()='Setup']/../..";
    public static final String GS_HOME_LOGOUT_BUTTON = "xpath://span[text()='Logout']/..";

    public static final String GS_SETUP_ENTITY_TEXT_FIELD = "xpath://div[@class='v-window-header'][text()='Setup']/ancestor::div[@class='popupContent']//span[text()='Entity']/ancestor::tr//td[@class='v-formlayout-contentcell']//input";
    public static final String GS_SETUP_TEMPLATE_TEXT_FIELD = "xpath://div[@class='v-window-header'][text()='Setup']/ancestor::div[@class='popupContent']//span[text()='Template']/ancestor::tr//td[@class='v-formlayout-contentcell']//input";
    public static final String GS_SETUP_DRAFT_TEXT_FIELD = "xpath://div[@class='v-window-header'][text()='Setup']/ancestor::div[@class='popupContent']//span[text()='Draft']/ancestor::tr//td[@class='v-formlayout-contentcell']//input";

    public static final String GS_COMPLETE_COMMENTS_BUTTON = "xpath://div[@class='v-window-header'][text()='Complete']/ancestor::div[@class='popupContent']//span[text()='Complete']/../..";
    public static final String GS_REJECT_COMMENTS_BUTTON = "xpath://div[@class='v-window-header'][text()='Reject']/ancestor::div[@class='popupContent']//span[text()='Reject']/../..";
    public static final String GS_CLOSE_COMMENTS_BUTTON = "xpath://div[@class='v-window-header'][text()='Close']/ancestor::div[@class='popupContent']//span[text()='Close']/../..";
    public static final String GS_REASSIGN_COMMENTS_BUTTON = "xpath://div[@class='v-window-header'][text()='Re-Assign']/ancestor::div[@class='popupContent']//div[@role='button']//span[text()='Re-Assign']/../..";
    public static final String GS_SETUP_CREATE_NEW_BUTTON = "xpath://span[text()='Create New']/../..";
    public static final String GS_MYWORKLIST_COMMENTS = "xpath://span[text()='Comments']/ancestor::tr//td[@class='v-formlayout-contentcell']/textarea";
    public static final String GS_MYWORKLIST_REASSSIGN = "xpath://span[text()='Re-Assign']/ancestor::tr//td[@class='v-formlayout-contentcell']/div/input";

    public static final String GS_GLOBAL_SEARCH_TEXTFIELD = "xpath://input[contains(@class,'gsGlobalSearchField')]";
    public static final String GS_GLOBAL_SEARCHTYPE_TEXTFIELD = "xpath://div[contains(@class, 'gsGlobalSearchCombo')]/input";
    public static final String GS_GLOBAL_SEARCH_BUTTON = "xpath://div[@role='button'][contains(@class,'v-button-gsSearchIcon')]";

    public static final String GS_ADD_DETAILS_BUTTON = "xpath://div[contains(@class,'button-gsGreenIcon')][@role='button']";

    public static final String GS_DELETE_DETAILS_RECORD = GS_ADD_DETAILS_BUTTON + "//preceding::div[@role='button'][1]";
    public static final String GS_DETAILS_VIEW = GS_ADD_DETAILS_BUTTON + "//preceding::div[@role='button'][3]";

    //POPUP CONTENT
    public static final String GS_POPUP_CONTENT = "//div[@class='popupContent']";
    public static final String GS_NOTIFICATION_CAPTION = XPATH + GS_POPUP_CONTENT + "//h1[@class='v-Notification-caption']";
    public static final String GS_NOTIFICATION_SUCCESS = "xpath://div[contains(@class,'Notification-success')]";
    public static final String GS_POPUP_HEADER_TABLE_XPATH = GS_POPUP_CONTENT + GS_HEADER_TABLE_XPATH;
    public static final String GS_POPUP_DATA_TABLE_XPATH = GS_POPUP_CONTENT + GS_DATA_TABLE_XPATH;
    public static final String GS_POPUP_DATA_TABLE_ROW = XPATH + GS_POPUP_DATA_TABLE_XPATH + "//tr/td/div[text()='%s']";
    public static final String GS_POPUP_LOOKUP_SEARCH_FIELD = XPATH + "(" + GS_POPUP_CONTENT + "//div[@class='filters-panel']//input)[%d]";
    public static final String GS_POPUP_DELETE_RECORD = XPATH + GS_POPUP_CONTENT + GS_DELETE_DETAILS_RECORD.replace(XPATH, "");
    public static final String GS_POPUP_CLOSE_WINDOW = XPATH + GS_POPUP_CONTENT + "//div[contains(@class,'closebox')][@role='button']";
    public static final String GS_POPUP_COMBO_BOX_LIST_VALUES = XPATH + GS_POPUP_CONTENT + "/div[@class='v-filterselect-suggestmenu']//tbody";

    public static final String GS_POPUP_DELETE_BUTTON = XPATH + "//div[text()='Are you sure you want to delete?']/ancestor::div[@class='popupContent']//span[text()='Delete']/../..";
    public static final String GS_POPUP_CANCEL_BUTTON = XPATH + GS_POPUP_CONTENT + "//span[text()='Cancel']/../..";

    //Modification Comments popup
    public static final String GS_POPUP_CONTENT_SAVE_BUTTON = "xpath://div[@class='popupContent']//span[text()='Save']/../..";
    public static final String GS_MODIFICATION_COMMENT_TEXTFIELD = "xpath://span[text()='Comment']/ancestor::tr//td[@class='v-formlayout-contentcell']/textarea";

    //Lock Comments Popup
    public static final String GS_POPUP_LOCK_COMMENT_TEXTFIELD = XPATH + GS_POPUP_CONTENT+"//div[@class='v-caption v-caption-LockCommTextarea']/following-sibling::textarea";

    //GS TAB Menus
    public static final String GS_TAB = "xpath://div[@class='v-captiontext'][text()='%s']";

    //Selecting Month and Year are not Automatable (or may require more attention), Hence concentrating on
    //Date selector as Month and Year are assumed to be already selected as per Current Month and year
    public static final String GS_POPUP_DATE_SELECTOR = "xpath://table[contains(@class,'calendarpanel')]//span[text()=%d]";
    public static final String GS_POPUP_SET_BUTTON = "xpath://div[contains(@class,'popupview')]//span[text()='Set']//ancestor::div[@role='button']";

    public static final String GS_CONFIRM_DIALOG_OK = "id:confirmdialog-ok-button";

    //Error message popup content
    public static final String GS_ERROR_POPUP_CONTENT = "xpath://div[@class='v-slot v-slot-h2 v-slot-redColor']/ancestor::div[@class='popupContent']";
    public static final String GS_ERROR_POPUP_RELOAD_ENTITY_BUTTON = GS_ERROR_POPUP_CONTENT + "//span[text()='Reload Entity']";
    public static final String GS_ERROR_POPUP_CONTINUE_EDIT_BUTTON = GS_ERROR_POPUP_CONTENT + "//span[text()='Continue Edit']";

}
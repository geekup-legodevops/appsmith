const formWidgetsPage = require("../../../../locators/FormWidgets.json");
const widgetLocators = require("../../../../locators/Widgets.json");
const dsl = require("../../../../fixtures/widgetPopupDsl.json");

describe("Dropdown Widget Functionality", function() {
  before(() => {
    cy.addDsl(dsl);
  });

  it("Verify dropdown width of Select widgets and menu button", function() {
    // Select
    cy.get(formWidgetsPage.selectwidget)
      .find(widgetLocators.dropdownSingleSelect)
      .invoke("outerWidth")
      .then((val) => {
        cy.get(formWidgetsPage.selectwidget)
          .find(widgetLocators.dropdownSingleSelect)
          .click({
            force: true,
          });
        cy.get(".select-popover-wrapper")
          .invoke("outerWidth")
          .should("eq", val);
      });
    // Menu Button
    cy.get(formWidgetsPage.menuButtonWidget)
      .find(widgetLocators.menuButton)
      .invoke("outerWidth")
      .should("eq", 147.1875);
    cy.get(formWidgetsPage.menuButtonWidget)
      .find(widgetLocators.menuButton)
      .click({
        force: true,
      });
    cy.get(".menu-button-popover")
      .invoke("outerWidth")
      .should("eq", 147.1875);

    // MultiSelect
    cy.get(formWidgetsPage.multiselectwidgetv2)
      .find(".rc-select-multiple")
      .invoke("width")
      .then((inputWidth) => {
        cy.get(formWidgetsPage.multiselectwidgetv2)
          .find(".rc-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".multi-select-dropdown")
          .invoke("width")
          .then((dropdownWidth) => {
            expect(Math.floor(inputWidth)).to.equal(Math.floor(dropdownWidth));
          });
      });
    //Multi tree Select
    cy.get(formWidgetsPage.multiselecttreeWidget)
      .find(".rc-tree-select-multiple")
      .invoke("width")
      .then((val) => {
        cy.get(formWidgetsPage.multiselecttreeWidget)
          .find(".rc-tree-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".tree-multiselect-dropdown")
          .invoke("outerWidth")
          .should("eq", val);
      });

    // Tree Select
    cy.get(formWidgetsPage.singleselecttreeWidget)
      .find(".rc-tree-select-single")
      .invoke("outerWidth")
      .then((val) => {
        cy.get(formWidgetsPage.singleselecttreeWidget)
          .find(".rc-tree-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".single-tree-select-dropdown")
          .invoke("outerWidth")
          .should("eq", val);
      });
  });

  it("Verify dropdown width of Select widgets with Label", function() {
    // Select
    cy.openPropertyPane("selectwidget");
    cy.testJsontext("labeltext", "Label");
    cy.get(formWidgetsPage.selectwidget)
      .find(widgetLocators.dropdownSingleSelect)
      .invoke("outerWidth")
      .then((val) => {
        cy.get(formWidgetsPage.selectwidget)
          .find(widgetLocators.dropdownSingleSelect)
          .click({
            force: true,
          });
        cy.get(".select-popover-wrapper")
          .invoke("outerWidth")
          .should("eq", val);
      });

    // MultiSelect
    cy.openPropertyPane("multiselectwidgetv2");
    cy.testJsontext("labeltext", "Label");
    cy.get(formWidgetsPage.multiselectwidgetv2)
      .find(".rc-select-multiple")
      .invoke("width")
      .then((val) => {
        cy.get(formWidgetsPage.multiselectwidgetv2)
          .find(".rc-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".multi-select-dropdown")
          .invoke("width")
          .should("eq", val);
      });
    //Multi tree Select
    cy.openPropertyPane("multiselecttreewidget");
    cy.testJsontext("labeltext", "Label");
    cy.get(formWidgetsPage.multiselecttreeWidget)
      .find(".rc-tree-select-multiple")
      .invoke("width")
      .then((val) => {
        cy.get(formWidgetsPage.multiselecttreeWidget)
          .find(".rc-tree-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".tree-multiselect-dropdown")
          .invoke("outerWidth")
          .should("eq", val);
      });
    // Tree Select
    cy.openPropertyPane("singleselecttreewidget");
    cy.testJsontext("labeltext", "Label");
    cy.get(formWidgetsPage.singleselecttreeWidget)
      .find(".rc-tree-select-single")
      .invoke("outerWidth")
      .then((val) => {
        cy.get(formWidgetsPage.singleselecttreeWidget)
          .find(".rc-tree-select-selection-search-input")
          .first()
          .focus({ force: true })
          .type("{uparrow}", { force: true });
        cy.get(".single-tree-select-dropdown")
          .invoke("outerWidth")
          .should("eq", val);
      });
  });
});

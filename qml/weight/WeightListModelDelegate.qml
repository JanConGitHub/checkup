import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import QtQuick.LocalStorage 2.0

import "BmiCalculator.js" as BmiCalculator
import "../Utility.js" as Utility
import "WeightDao.js" as WeightDao


   /*
     Delegate component used to display a saved weight measure (value, date, notes...)
   */
   Item {
        id: weightPressureItem
        width: weightDiaryPage.width
        height: units.gu(16) /* heigth of the rectangle */

        /* create a container for each item */
        Rectangle {
            id: background
            x: 2; y: 2; width: parent.width - x*2; height: parent.height - y*1
            border.color: "black"
            radius: 5
            color: theme.palette.normal.background
        }

        /* This mouse region covers the entire delegate */
        MouseArea {
            id: selectableMouseArea
            anchors.fill: parent

            onClicked: {
                /* move the highlight component to the currently selected item */
                listView.currentIndex = index
            }
        }

        /* create a row for each entry in the Model */
        Row {
            id: topLayout
            x: 10; y: 7; height: background.height; width: parent.width
            spacing: units.gu(4)

            Column {
                id: containerColumn
                width: topLayout.width - units.gu(10);
                height: weightPressureItem.height
                anchors.verticalCenter: topLayout.Center
                spacing: units.gu(0.8)

                Row{
                    id:weightValueRow
                    spacing:units.gu(1)
                    Label {
                         id: valueLabel
                         anchors.verticalCenter: valueTextField.verticalCenter
                         text: i18n.tr("Value")+":"
                         font.bold: true
                         fontSize: "medium"
                    }

                    TextField {
                          id: valueTextField
                          hasClearButton: false
                          text: value
                          width: Utility.getTextFieldReductionFactor()
                          height:units.gu(4)
                          enabled: false
                    }

                    Label {
                          id: weightUniOfMeasureLabel
                          anchors.verticalCenter: valueTextField.verticalCenter
                          text: weightDiaryPage.weightUnitOfMeasure
                          font.bold: true
                          fontSize: "medium"
                    }
                }

                Row{
                    id:bmiRow
                    spacing: valueLabel.text.length + units.gu(1)

                    Label {
                          id: bmiLabel
                          anchors.verticalCenter: bmiLabelField.verticalCenter
                          text:  i18n.tr("BMI")+":"
                          font.bold: true
                          fontSize: "medium"
                    }

                    Label {
                          id: bmiLabelField
                          x:valueTextField.x
                          text: bmi
                    }
                }

                Row{
                    id:dateRow
                    spacing: valueLabel.text.length + units.gu(1)
                    Label {
                          id: dateLabel
                          anchors.verticalCenter: dateTextField.verticalCenter
                          text: i18n.tr("Date")+": "
                          font.bold: true
                          fontSize: "medium"
                    }
                    /* date is not editable. To update it, delete item and insert again */
                    Label {
                          id: dateTextField
                          x:valueTextField.x
                          text: Qt.formatDateTime(date, "dd MMMM yyyy")
                    }
                }

                Row{
                    id:notesRow
                    spacing: valueLabel.text.length + units.gu(2)
                    Label {
                          id: notesLabel
                          anchors.verticalCenter: notesButton.verticalCenter
                          text: i18n.tr("Notes")
                          font.bold: true
                          fontSize: "medium"
                    }

                    Button{
                      id:notesButton
                      x:valueTextField.x
                      text: i18n.tr("Edit...")
                      enabled:false
                      onClicked: {
                          weightDiaryPage.itemNotes = notes;
                          PopupUtils.open(updateNotesItem);
                      }
                    }
                }
            }

            Column{

              id: manageUrlColumn
              height: parent.height
              width: units.gu(7);
              spacing: units.gu(1)

              Rectangle {
                  id: placeholder2
                  color: "transparent"
                  width: parent.width
                  height: units.gu(0.1)
              }

              //---- Delete Item icon
              Row{
                  id:deleteUrlRow
                  Icon {
                      id: deleteUrlIcon
                      width: units.gu(3)
                      height: units.gu(3)
                      name: "delete"

                      MouseArea {
                          id: deleteUrlArea
                          width: deleteUrlIcon.width
                          height: deleteUrlIcon.height
                          onClicked: {
                              weightDiaryPage.selectedItem = id;
                              PopupUtils.open(confirmDeleteItem);
                          }
                      }
                  }
              }

              //---- Edit Item icon
              Row{
                  id:editUrlRow
                  Icon {
                      id: editUrlIcon
                      width: units.gu(3)
                      height: units.gu(3)
                      name: "edit"

                      MouseArea {
                          width: editUrlIcon.width
                          height: editUrlIcon.height
                          onClicked: {
                              /* set the id and notes of the target item */
                              weightDiaryPage.selectedItem = id;
                              weightDiaryPage.itemNotes = notes;

                              valueTextField.enabled = true;
                              dateTextField.enabled = true;
                              notesButton.enabled = true;
                              saveRow.visible = true;
                          }
                      }
                  }
              }

              //------ Save/Update Item (shown when edit icon is selected) ----
              Row{
                  id:saveRow
                  visible: false

                  Icon {
                        id: editUrlIcon2
                        width: units.gu(3)
                        height: units.gu(3)
                        name: "save"

                        MouseArea {
                            width: editUrlIcon.width
                            height: editUrlIcon.height
                            onClicked: {
                                weightDiaryPage.selectedItem = id;
                                /* update BMI with new weigth */
                                var newBmiValue = BmiCalculator.calculateBmi(valueTextField.text, weightDiaryPage.userHeigth, weightDiaryPage.weightUnitOfMeasure, weightDiaryPage.heigthUnitOfMeasure);
                                bmiLabelField.text = newBmiValue;
                                //console.log("NEW updated BMI:"+newBmiValue);

                                WeightDao.updateWeightMeasure(valueTextField.text, newBmiValue, weightDiaryPage.itemNotes, weightDiaryPage.selectedItem );
                                WeightDao.loadWeightData(dateFromButton.text, dateToButton.text); //refresh

                                //after edit save, lock the fields
                                valueTextField.enabled = false;
                                dateTextField.enabled = true;
                                notesButton.enabled = false;
                                saveRow.visible = false;
                            }
                        }
                    }
                }

            }
        }
    }

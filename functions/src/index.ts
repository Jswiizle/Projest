import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

// const db = admin.firestore();

exports.currentUserUpdated = functions.firestore.document('/Projects/{docID}').onUpdate((event, context) => {

    let projectName = String(event.after.get('title'))

    let projectOwnerToken = String(event.after.get('ownerToken'))

    let oldRatedByUID = event.before.get('ratedByUID')
    let newRatedByUID = event.after.get('ratedByUID')

    let oldFeedbackArray = event.before.get('feedbackArray')
    let newFeedbackArray = event.after.get('feedbackArray')

    var bodyText = ""

    if (String(oldRatedByUID) != String(newRatedByUID)) {

        if (projectOwnerToken) {

            if (projectOwnerToken != "" || projectOwnerToken != null) {

                bodyText = "You have new feedback on your project"

                const message = {
        
                    notification: {
                        title: "Incoming Feedback",
                        body: "You have new feedback on your project: '" + projectName + "'"
                    },
            
                    token: projectOwnerToken
                }
                
                return admin.messaging().send(message)
                .catch(error=> {
            
                    console.error("FCM Failed", error)
                    console.log(error)
                })
            }
        }
    }

    else if (oldFeedbackArray != newFeedbackArray) {

        // Feedback was rated

        for (const feedback of newFeedbackArray) {

            for (const oldFback of oldFeedbackArray) {

                if (feedback.senderID == oldFback.senderID && feedback.rated != oldFback.rated) {

                    if (feedback.senderToken) {

                        if (feedback.senderToken != "") {

                            const newToken : string = feedback.senderToken 
                            
                            bodyText = "Your feedback on '" + projectName + "' has been rated"
    
                            const message = {
    
                                notification: {
                                    title: "Feedback Rated",
                                    body: bodyText
                                },
                        
                                token: newToken
                            }
                                            
                            return admin.messaging().send(message)
                            .catch(error=> {
                        
                                console.error("FCM Failed", error)
                                console.log(error)
                            })
                        }
                    }
                }
            }
        }
    }

    else {return null}

    return null
})

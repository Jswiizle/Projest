import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

exports.currentUserUpdated = functions.firestore.document('/Projects/{docID}').onUpdate((event, context) => {

    let projectName = String(event.after.get('title'))
    let projectOwnerTokens : Array<String> = event.after.get('ownerTokens')

    let oldRatedByUids = event.before.get('ratedByUids')
    let newRatedByUids = event.after.get('ratedByUids')

    let oldFeedbackArray = event.before.get('feedbackArray')
    let newFeedbackArray = event.after.get('feedbackArray')


    if (Array<String>(oldRatedByUids) != Array<String>(newRatedByUids)) {

        //Feedback received

        if (projectOwnerTokens) {

            for (var t of projectOwnerTokens) {

                console.log(t)

                const message = {

                    data: {
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
        
                    notification: {
                        title: "Incoming Feedback",
                        body: "You have new feedback on your project: '" + projectName + "'",
                    },
            
                    token: String(t)
                }
                
                admin.messaging().send(message)
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

                    if (feedback.senderTokens) {

                        for (let t in feedback.senderTokens) {

                            const message = {
    
                                notification: {
                                    title: "Feedback Rated",
                                    body: "Your feedback on '" + projectName + "' has been rated"
                                },
                        
                                token: t
                            }
                                            
                            admin.messaging().send(message)
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

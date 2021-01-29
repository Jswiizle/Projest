import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

exports.currentUserUpdated = functions.firestore.document('/Projects/{docID}').onUpdate((event, context) => {

    let projectName = String(event.after.get('title'))
    let projectId = String(event.after.get('id'))
    let projectOwnerTokens : Array<String> = event.after.get('ownerTokens')

    let oldRatedByUids = event.before.get('ratedByUids')
    let newRatedByUids = event.after.get('ratedByUids')

    let oldFeedbackArray = event.before.get('feedbackArray')
    let newFeedbackArray = event.after.get('feedbackArray')


    if (Array<String>(oldRatedByUids) != Array<String>(newRatedByUids)) {

        //Feedback received

        if (projectOwnerTokens) {

                const message = {
                    
                    notification: {
                        title: "Feedback Received",
                        body: "You have new feedback on your project: '" + projectName + "'",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },

                    data: {
                        pId: projectId,
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    }
                }

                const options = {
                    priority: "high",
                    mutableContent: true,
                    contentAvailable: true,
                    apnsPushType: "background"
                }

                admin.messaging().sendToDevice(projectOwnerTokens as string[], message, options).catch(error=> {
                    console.error("FCM Failed", error)
                    console.log(error)
                })
            }
    }

    else if (oldFeedbackArray != newFeedbackArray) {

        // Feedback was rated

        for (const feedback of newFeedbackArray) {

            for (const oldFback of oldFeedbackArray) {

                if (feedback.senderID == oldFback.senderID && feedback.rated != oldFback.rated) {

                    if (feedback.senderTokens) {

                        const message = {
    
                                notification: {
                                    title: "Feedback Rated",
                                    body: "Your feedback on '" + projectName + "' has been rated"
                                },
                        
                                tokens: projectOwnerTokens as string[]
                            }
                                            
                        admin.messaging().sendMulticast(message).catch(error=> {
        
                            console.error("FCM Failed", error)
                            console.log(error)
                        })
                    }
                }
            }
        }
    }

    else {return null}

    return null
})

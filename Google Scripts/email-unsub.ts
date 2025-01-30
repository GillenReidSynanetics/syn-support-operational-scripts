function unsubscribeEmails() {
  const threads = GmailApp.search('unsubscribe');
  const unsubscribeLinks = [];
  
  threads.forEach(thread => {
    const messages = thread.getMessages();
    messages.forEach(message => {
      const body = message.getBody();
      const regex = /https?:\/\/[^\s"']*unsubscribe[^\s"']*/gi;
      const links = body.match(regex);
      if (links) {
        unsubscribeLinks.push(...links);
      }
    });
  });

  Logger.log(`Found ${unsubscribeLinks.length} unsubscribe links.`);
  
  unsubscribeLinks.forEach(link => {
    try {
      const response = UrlFetchApp.fetch(link);
      if (response.getResponseCode() === 200) {
        Logger.log(`Successfully unsubscribed from: ${link}`);
      } else {
        Logger.log(`Failed to unsubscribe from: ${link}`);
      }
    } catch (error) {
      Logger.log(`Error unsubscribing from: ${link}`);
    }
  });
}

//
//  FormItemSampleData.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

import Lumiform

extension FormItem {
    static func simpleSampleData() -> (item: FormItem, data: Data) {
        let jsonString = """
        {
          "type": "page",
          "title": "Main Page",
          "items": [
            {
              "type": "section",
              "title": "Introduction",
              "items": [
                {
                  "type": "text",
                  "content": "Welcome to the main page!"
                },
                {
                  "type": "image",
                  "src": "https://robohash.org/280?&set=set4&size=400x400",
                  "title": "Welcome Image"
                }
              ]
            }]
        }    
        """

        let form: FormItem = .page(Page(title: "Main Page", items: [
            .section(Section(title: "Introduction", items: [
                .question(.text(TextQuestion(title: "Welcome to the main page!"))),
                .question(.image(ImageQuestion(title: "Welcome Image", sourceURL: URL(string: "https://robohash.org/280?&set=set4&size=400x400")!)))
            ]))
        ]))

        return (form, Data(jsonString.utf8))
    }

    static func recursiveSampleData() -> (item: FormItem, data: Data) {
        let jsonString = """
        {
              "type": "page",
              "title": "Main Page",
              "items": [
                {
                  "type": "section",
                  "title": "Introduction",
                  "items": [
                    {
                      "type": "text",
                      "content": "Welcome to the main page!"
                    },
                    {
                      "type": "image",
                      "src": "https://robohash.org/280?&set=set4&size=400x400",
                      "title": "Welcome Image"
                    }
                  ]
                },
                {
                  "type": "section",
                  "title": "Chapter 1",
                  "items": [
                    {
                      "type": "text",
                      "content": "This is the first chapter."
                    },
                    {
                      "type": "section",
                      "title": "Subsection 1.1",
                      "items": [
                        {
                          "type": "text",
                          "content": "This is a subsection under Chapter 1."
                        },
                        {
                          "type": "image",
                          "src": "https://robohash.org/100?&set=set4&size=400x400",
                          "title": "Chapter 1 Image"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "page",
                  "title": "Second Page",
                  "items": [
                    {
                      "type": "section",
                      "title": "Chapter 2",
                      "items": [
                        {
                          "type": "text",
                          "content": "This is the second chapter."
                        },
                        {
                          "type": "text",
                          "content": "What is the main topic of Chapter 2?"
                        }
                      ]
                    }
                  ]
                }
              ]
            } 
        """

        let form = FormItem.page(Page(title: "Main Page", items: [
            FormItem.section(Section(title: "Introduction", items: [
                FormItem.question(Question.text(TextQuestion(title: "Welcome to the main page!"))),
                FormItem.question(Question.image(ImageQuestion(title: "Welcome Image", sourceURL: URL(string: "https://robohash.org/280?&set=set4&size=400x400")!)))
            ])),
            FormItem.section(Section(title: "Chapter 1", items: [
                FormItem.question(Question.text(TextQuestion(title: "This is the first chapter."))),
                FormItem.section(Section(title: "Subsection 1.1", items: [
                    FormItem.question(Question.text(TextQuestion(title: "This is a subsection under Chapter 1."))),
                    FormItem.question(Question.image(ImageQuestion(title: "Chapter 1 Image", sourceURL: URL(string: "https://robohash.org/100?&set=set4&size=400x400")!)))
                ]))
            ])),
            FormItem.page(Page(title: "Second Page", items: [
                FormItem.section(Section(title: "Chapter 2", items: [
                    FormItem.question(Question.text(TextQuestion(title: "This is the second chapter."))),
                    FormItem.question(Question.text(TextQuestion(title: "What is the main topic of Chapter 2?")))
                ]))
            ]))
        ]))

        return (form, Data(jsonString.utf8))
    }
}
